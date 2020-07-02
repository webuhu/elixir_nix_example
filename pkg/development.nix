{ pkgs, elixir, hex, postgresql, elixir_prepare, MIX_ENV, MIX_REBAR3, LANG }:

rec {
  watchexec = pkgs.watchexec;

  nix_shell_prompt_override = ''
    export PS1='\e[0;32m[nix-shell@\h] \W>\e[m '
  '';

  shell_setup = nix_shell_prompt_override;

  # enable IEx shell history
  ERL_AFLAGS = "-kernel shell_history enabled";

  elixir_import_deps = ''
    mkdir -p deps
    cp -r $elixir_prepare/deps/. deps/
    chmod -R 700 deps
  '';

  elixir_import_build = ''
    mkdir -p _build
    cp -r $elixir_prepare/_build/. _build/
    chmod -R 700 _build
  '';

  elixir_setup = ''
    ${elixir_import_deps}
    ${elixir_import_build}

    mix ecto.migrate --quiet
    # mix phx.server

    cleanup_elixir() {
      echo 'cleanup elixir ...'

      rm -rf deps _build
    }
  '';

  postgresql_setup = ''
    export PGDATA=$(mktemp --directory)

    # PG_LISTENING_ADDRESS default to localhost
    : ''${PG_LISTENING_ADDRESS:=127.0.0.1}

    initdb --locale=C --encoding=UTF8 --auth-local=peer --auth-host=scram-sha-256 > /dev/null || exit

    # set -m fixes ^C kill postgresql
    set -m
    # get options for -o from: `postgres --help`
    pg_ctl -l $PGDATA/postgresql.log -o "-k $PGDATA -h $PG_LISTENING_ADDRESS" start || exit

    createdb -h $PGDATA database_name
    psql -h $PGDATA database_name -c "COMMENT ON DATABASE sici_dev IS 'Database for Development, Testing & CI'" > /dev/null

    # createuser postgres --createdb
    if [ $MIX_ENV = 'dev' ]
    then
      psql -h $PGDATA database_name -c "CREATE USER dev PASSWORD 'secret'" > /dev/null
    fi

    cleanup_postgres() {
      echo 'cleanup postgres ...'

      pg_ctl stop --silent
      rm -rf $NIX_SHELL_DIR/.postgresql
    }
  '';

  env = pkgs.mkShell {
    inherit elixir_prepare MIX_ENV MIX_REBAR3 LANG;
    inherit ERL_AFLAGS;
    CLEANED_ERL_LIBS = "${hex}/lib/erlang/lib";
    nativeBuildInputs = [elixir hex postgresql pkgs.less];
    shellHook = ''
      export ERL_LIBS=$CLEANED_ERL_LIBS

      # DB only listening on socket - no TCP.
      # Necessary to run tests concurrently.
      if [ $MIX_ENV = 'test' ]
      then
        export PG_LISTENING_ADDRESS="'''"
      fi

      ${shell_setup}
      ${postgresql_setup}
      ${elixir_setup}

      cleanup_all() {
        cleanup_elixir
        cleanup_postgres
      }
      trap cleanup_all EXIT
    '';
  };

  watch = pkgs.mkShell {
    inherit elixir_prepare MIX_ENV MIX_REBAR3 LANG;
    CLEANED_ERL_LIBS = "${hex}/lib/erlang/lib";
    nativeBuildInputs = [elixir hex postgresql watchexec];
    shellHook = ''
      export ERL_LIBS=$CLEANED_ERL_LIBS

      ${shell_setup}
      ${postgresql_setup}
      ${elixir_setup}

      cleanup_all() {
        cleanup_elixir
        cleanup_postgres
      }
      trap cleanup_all EXIT

      echo -e "\e[0;32mwatch mode starting ...\e[m"
      watchexec --exts ex --restart "mix run --no-halt &"
    '';
  };
}
