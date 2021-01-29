{ pkgs ? import ./pkg/_pkgs.nix, env ? "dev", release_name ? "example" }:

rec {
  erlang = pkgs.erlangR23;
  elixir = pkgs.buildPackages.beam.packages.erlangR23.elixir;
  nodejs = pkgs.nodejs-15_x;

  postgresql = pkgs.postgresql_13;

  MIX_HOME = hex;
  MIX_REBAR3 = "${rebar3}/bin/rebar3";
  MIX_ENV = env;
  LANG = "C.UTF-8";

  hex = pkgs.callPackage ./pkg/hex.nix {
    inherit elixir LANG;
  };

  rebar3 = pkgs.callPackage ./pkg/rebar3.nix {
    inherit erlang;
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  mix_deps = pkgs.callPackage ./pkg/mix_deps.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  mix_build = pkgs.callPackage ./pkg/mix_build.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash (impure fetch)
  node_modules = pkgs.callPackage ./pkg/node_modules.nix {
    inherit nodejs;
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash & hashed inputs (impure fetch)
  # Works probably only for env "dev" → mix.exs
  docs = pkgs.callPackage ./pkg/docs.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps mix_build;
    # hash is also changing with env
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  # Needs `--option sandbox relaxed` if used without setting hash & hashed inputs (impure fetch)
  release = pkgs.callPackage ./pkg/release.nix {
    inherit elixir MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    inherit mix_deps mix_build release_name;
    inherit node_modules;
    inherit nodejs;
    # hash is also changing with env & release_name
    # hash = "sha256:${pkgs.lib.fakeSha256}";
  };

  base_hooks = ''
    # short default prompt
    export PS1='\e[0;32m[nix-shell@\h] \W>\e[m '
  '';
  elixir_hooks = ''
    # enable IEx shell history
    export ERL_AFLAGS="-kernel shell_history enabled"

    # fix double paths in ERL_LIBS caused by Nix Elixir build
    unset ERL_LIBS
  '';
  cleanup_elixir = ''
    cleanup_elixir() {
      echo 'cleanup elixir ...'

      rm -rf deps _build
    }
  '';
  hooks = base_hooks + elixir_hooks;

  env_plain = pkgs.mkShell {
    name = "env_plain";
    inherit MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    MIX_DEPS_PATH = ".nix/deps";
    MIX_BUILD_ROOT = ".nix/_build";
    HEX_HOME = ".nix/hex";
    buildInputs = [
      elixir
      nodejs
      pkgs.inotify-tools
    ];
    shellHook = hooks;
  };

  # to be used when MIX_ENV is integrated again
  # fix_db_listening_in_test = ''
  #   # DB only listening on socket - no TCP.
  #   # Necessary to run tests concurrently.
  #   if [ $MIX_ENV = 'test' ]
  #   then
  #     export PG_LISTENING_ADDRESS="'''"
  #   fi
  # ''

  # TODO: database name to variable ...
  postgresql_setup = ''
    export PGDATA=$(mktemp --directory)

    # PG_LISTENING_ADDRESS default to localhost
    # TODO: Check that!
    # : ''${PG_LISTENING_ADDRESS:=127.0.0.1}
    PG_LISTENING_ADDRESS='127.0.0.1'

    initdb --locale=C --encoding=UTF8 --auth-local=peer --auth-host=scram-sha-256 > /dev/null || exit

    # set -m fixes ^C kill postgresql
    set -m
    # get options for -o from: `postgres --help`
    pg_ctl -l $PGDATA/postgresql.log -o "-k $PGDATA -h $PG_LISTENING_ADDRESS" start || exit

    createdb -h $PGDATA elixir_nix_example_dev
    psql -h $PGDATA elixir_nix_example_dev -c "COMMENT ON DATABASE elixir_nix_example_dev IS 'Database for Development, Testing & CI'" > /dev/null

    # createuser postgres --createdb
    # if [ $MIX_ENV = 'dev' ]
    # then
    #   psql -h $PGDATA elixir_nix_example_dev -c "CREATE USER dev PASSWORD 'secret'" > /dev/null
    # fi

    cleanup_postgres() {
      echo 'cleanup postgres ...'

      pg_ctl stop --silent
      rm -rf $NIX_SHELL_DIR/.postgresql
    }
  '';

  env_full = pkgs.mkShell {
    name = "env_full";
    inherit MIX_HOME MIX_REBAR3 mix_deps MIX_ENV LANG;
    MIX_DEPS_PATH = ".nix/deps";
    MIX_BUILD_ROOT = ".nix/_build";
    HEX_HOME = ".nix/hex";
    buildInputs = [
      elixir
      nodejs
      pkgs.inotify-tools
      postgresql
    ];
    shellHook = hooks + postgresql_setup + ''
      ln -s $mix_deps deps

      cleanup_elixir() {
        echo 'cleanup elixir ...'

        rm -rf deps _build
      }

      cleanup_all() {
        cleanup_elixir
        cleanup_postgres
      }
      trap cleanup_all EXIT
    '';
  };
}
