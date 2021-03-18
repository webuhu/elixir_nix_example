{ pkgs ? import ./pkg/_pkgs.nix, MIX_ENV ? "dev", release_name ? "example" }:

rec {
  erlang = pkgs.beam_nox.interpreters.erlangR23;
  elixir = pkgs.buildPackages.beam_nox.packages.erlangR23.elixir_1_11;
  nodejs = pkgs.nodejs-15_x;

  postgresql = pkgs.postgresql_13;

  MIX_HOME = hex;
  MIX_REBAR3 = "${rebar3}/bin/rebar3";
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

  base_hook = ''
    # short default prompt
    export PS1='\e[0;32m[nix-shell@\h] \W>\e[m '
  '';
  elixir_hook = ''
    # enable IEx shell history
    export ERL_AFLAGS="-kernel shell_history enabled"

    # fix double paths in ERL_LIBS caused by Nix Elixir build
    unset ERL_LIBS
  '';
  hooks = base_hook + elixir_hook;

  env = pkgs.mkShell {
    name = "env";
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

  postgresql_setup = import ./pkg/temporary_postgresql_db.nix {};

  env_with_db = pkgs.mkShell {
    name = "env_with_db";
    inherit MIX_HOME MIX_REBAR3 MIX_ENV LANG;
    MIX_DEPS_PATH = ".nix/deps";
    MIX_BUILD_ROOT = ".nix/_build";
    HEX_HOME = ".nix/hex";
    buildInputs = [
      elixir
      nodejs
      pkgs.inotify-tools
      postgresql
    ];
    shellHook = hooks + postgresql_setup;
  };
}
