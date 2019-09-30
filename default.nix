{ pkgs ? import ./pkg/_pkgs.nix, environment ? "dev" }:

rec {
  elixir = pkgs.buildPackages.beam.packages.erlangR22.elixir_1_9;
  hex = pkgs.buildPackages.beam.packages.erlangR22.hex;
  rebar3 = pkgs.buildPackages.beam.packages.erlangR22.rebar3;

  postgresql = pkgs.postgresql_11;

  MIX_ENV = "${environment}";
  MIX_REBAR3 = "${rebar3}/bin/rebar3";
  LANG = "C.UTF-8"; # redundant with [Patch](https://github.com/NixOS/nixpkgs/pull/61202)

  dev = import ./pkg/development.nix { inherit pkgs elixir hex postgresql elixir_prepare MIX_ENV MIX_REBAR3 LANG; };
  docs = import ./pkg/docs.nix { inherit pkgs elixir hex elixir_prepare MIX_ENV MIX_REBAR3 LANG; };
  pkgs_update = import ./pkg/update.nix { inherit pkgs elixir LANG; };

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

  # needs `--option sandbox relaxed` (impure fetch)
  elixir_prepare = pkgs.stdenv.mkDerivation rec {
    __noChroot = true;
    name = "elixir_prepare";
    mix_exs = ./mix.exs;
    mix_lock = ./mix.lock;
    FIXED_ERL_LIBS = "${hex}/lib/erlang/lib";
    inherit MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      export ERL_LIBS=$FIXED_ERL_LIBS

      export HEX_HOME=$PWD/.hex
      export MIX_HOME=$PWD/.mix
      export MIX_ARCHIVES=$MIX_HOME/archives

      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock

      mix deps.get
      mix compile

      mkdir $out
      cp -r ./_build/. $out/_build/
      cp -r ./deps/. $out/deps/
    '';
  };

  release = pkgs.stdenv.mkDerivation rec {
    name = "release";
    config = ./config;
    lib = ./lib;
    mix_exs = ./mix.exs;
    mix_lock = ./mix.lock;
    inherit elixir_prepare MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      ln -s $config config
      ln -s $lib lib
      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock

      ${elixir_import_deps}
      ${elixir_import_build}

      HOME=.
      mix release

      mkdir $out
      cp -r _build/${MIX_ENV}/rel/seed/. $out/
    '';
  };
}
