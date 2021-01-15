{ stdenv, elixir, MIX_HOME, MIX_REBAR3, nodejs, mix_deps, LANG, env ? "prod" }:

with import ./_pkgs.nix;
let
  MIX_ENV = env;

in stdenv.mkDerivation rec {
  name = "release";
  build = ../_build;
  assets = ../assets;
  config = ../config;
  lib = ../lib;
  priv = ../priv;
  rel = ../rel;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  inherit MIX_ENV MIX_HOME MIX_REBAR3 LANG;
  depsBuildTarget = [
    elixir
    nodejs
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $assets assets
    ln -s $config config
    ln -s $mix_deps deps
    ln -s $lib lib
    ln -s $rel rel
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $build/. _build/
    chmod -R 755 _build

    cp -r $priv/. priv/
    chmod -R 755 priv

    mix phx.digest

    mkdir $out
    mix release --no-compile --path $out --quiet
  '';
}
