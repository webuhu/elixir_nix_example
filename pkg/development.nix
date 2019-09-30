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

    mix ecto.migrate
    # mix phx.server

    cleanup_elixir() {
      echo 'cleanup elixir ...'

      rm -rf deps _build
    }
  '';

  postgresql_setup = ''
    mkdir -p .nix-shell
    export NIX_SHELL_DIR=$PWD/.nix-shell

    mkdir -p $NIX_SHELL_DIR/.postgresql
    export PGDATA=$NIX_SHELL_DIR/.postgresql

    initdb --locale=C --encoding=UTF8 --auth-local=peer --auth-host=scram-sha-256 > /dev/null || exit

    # set -m fixes ^C kill postgresql
    set -m
    # get options for -o from: `postgres --help`
    pg_ctl -l $PGDATA/postgresql.log -o "-k $PGDATA" start || exit

    createdb -h $PGDATA simplicity
    psql -h $PGDATA simplicity -c "CREATE EXTENSION IF NOT EXISTS postgis;" > /dev/null

    # createuser postgres --createdb
    psql -h $PGDATA simplicity -c "CREATE USER postgres WITH CREATEDB PASSWORD 'postgres';" > /dev/null

    cleanup_postgres() {
      echo 'cleanup postgres ...'

      pg_ctl stop --silent
      rm -rf $NIX_SHELL_DIR/.postgresql
    }
  '';

  env = pkgs.mkShell {
    inherit elixir_prepare MIX_ENV MIX_REBAR3 LANG;
    inherit ERL_AFLAGS;
    nativeBuildInputs = [elixir hex postgresql pkgs.less];
    shellHook = ''
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
    nativeBuildInputs = [elixir hex postgresql watchexec];
    shellHook = ''
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
