{ pkgs ? import ./pkg/_pkgs.nix, environment ? "dev" }:

rec {
  elixir = pkgs.buildPackages.beam.packages.erlangR22.elixir_1_9;
  hex = pkgs.buildPackages.beam.packages.erlangR22.hex;
  rebar3 = pkgs.buildPackages.beam.packages.erlangR22.rebar3;

  MIX_ENV = "${environment}";
  MIX_REBAR3 = "${rebar3}/bin/rebar3";
  LANG = "C.UTF-8"; # deprecated when is set default in Nix

  development = import ./pkg/development.nix { inherit pkgs elixir hex deps build MIX_ENV MIX_REBAR3 LANG; };
  testing = import ./pkg/testing.nix { inherit pkgs elixir hex deps build MIX_ENV MIX_REBAR3 LANG; };
  pkgs_update = import ./pkg/update.nix { inherit pkgs elixir LANG; };

  deps = pkgs.stdenv.mkDerivation rec {
    name = "deps";
    mix_exs = ./mix.exs;
    mix_lock = ./mix.lock;
    inherit MIX_ENV LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock
      HOME=.
      mix deps.get
      mkdir $out
      cp -r ./deps/. $out/
    '';
  };

  build = pkgs.stdenv.mkDerivation rec {
    name = "build";
    mix_exs = ./mix.exs;
    mix_lock = ./mix.lock;
    inherit deps MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock

      mkdir -p deps
      cp -r $deps/. deps/
      chmod -R 700 deps

      HOME=.
      mix compile
      mkdir $out
      cp -r ./_build/. $out/
    '';
  };

  docs = pkgs.stdenv.mkDerivation rec {
    name = "docs";
    lib = ./lib;
    mix_exs = ./mix.exs;
    mix_lock = ./mix.lock;
    inherit deps build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      ln -s $lib lib
      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock

      mkdir -p deps
      cp -r $deps/. deps/
      chmod -R 700 deps

      mkdir -p _build
      cp -r $build/. _build/
      chmod -R 700 _build

      HOME=.
      mix docs
      mkdir $out
      cp -r ./doc/. $out/
    '';
  };

  release = pkgs.stdenv.mkDerivation rec {
    name = "release";
    config = ./config;
    lib = ./lib;
    mix_exs = ./mix.exs;
    mix_lock = ./mix.lock;

    inherit deps build MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup
      ln -s $config config
      ln -s $lib lib
      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock

      mkdir -p deps
      cp -r $deps/. deps/
      chmod -R 700 deps

      mkdir -p _build
      cp -r $build/. _build/
      chmod -R 700 _build

      HOME=.
      mix release

      mkdir $out
      cp -r _build/${MIX_ENV}/rel/seed/. $out/
      cp .env $out/
    '';
  };
}
