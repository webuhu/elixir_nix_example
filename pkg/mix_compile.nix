{ stdenvNoCC, lib, elixir, MIX_PATH, MIX_REBAR3, MIX_ENV, LANG, mix_deps, mix_deps_build, hash ? null }:

stdenvNoCC.mkDerivation rec {
  __noChroot = if hash == null then true else false;
  name = "mix_build";
  config = ../config;
  lib_dir = ../lib;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  inherit MIX_PATH MIX_REBAR3 MIX_ENV LANG mix_deps mix_deps_build;
  nativeBuildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $config config
    ln -s $lib_dir lib
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    cp -r $mix_deps_build/. _build/
    chmod -R 700 _build

    mix compile

    mkdir $out
    cp -r _build/$MIX_ENV/. $out/$MIX_ENV/
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
}
