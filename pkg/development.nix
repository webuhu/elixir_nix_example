{ pkgs, elixir, hex, elixir_deps, elixir_build, MIX_ENV, MIX_REBAR3, LANG }:

rec {
  watchexec = pkgs.watchexec;

  common_script = ''
    export PS1='\e[0;32m[nix-shell@\h] \W>\e[m '

    # enables iex shell history
    export ERL_AFLAGS="-kernel shell_history enabled"

    function cleanup() {
      rm -rf deps _build
    }
    trap cleanup EXIT

    mkdir -p deps
    cp -r $elixir_deps/. deps/
    chmod -R 700 deps

    mkdir -p _build
    cp -r $elixir_build/. _build/
    chmod -R 700 _build
  '';

  env = pkgs.mkShell {
    inherit elixir_deps elixir_build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir];
    shellHook = ''
      ${common_script}
    '';
  };

  run = pkgs.mkShell {
    inherit elixir_deps elixir_build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    shellHook = ''
      ${common_script}

      mix run --no-halt
    '';
  };

  watch = pkgs.mkShell {
    inherit elixir_deps elixir_build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex watchexec];
    shellHook = ''
      ${common_script}

      watchexec --exts ex --restart "mix run --no-halt &"
    '';
  };

  iex = pkgs.mkShell {
    inherit elixir_deps elixir_build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    shellHook = ''
      ${common_script}

      iex -S mix
    '';
  };

  phx_server = pkgs.mkShell {
    inherit elixir_deps elixir_build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex pkgs.postgresql_11];
    shellHook = ''
      function cleanup() {
        pg_ctl stop

        rm -rf deps _build .postgres
      }
      trap cleanup EXIT

      mkdir -p deps
      cp -r $elixir_deps/. deps/
      chmod -R 700 deps

      mkdir -p _build
      cp -r $elixir_build/. _build/
      chmod -R 700 _build

      HOME=.
      export PGDATA=.postgres
      initdb
      pg_ctl start
      createdb database_name

      psql database_name -c "CREATE USER postgres WITH PASSWORD 'postgres';"

      mix ecto.migrate
      mix phx.server
    '';
  };
}
