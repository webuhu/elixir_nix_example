{ stdenvNoCC, lib, elixir, MIX_PATH, MIX_REBAR3, MIX_ENV, LANG, mix_deps, hash ? null }:

stdenvNoCC.mkDerivation rec {
  __noChroot = if hash == null then true else false;
  name = "mix_deps_build";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  inherit MIX_PATH MIX_REBAR3 MIX_ENV LANG mix_deps;
  nativeBuildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $config config
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    mix deps.compile

    mkdir $out
    cp -r _build/$MIX_ENV/. $out/$MIX_ENV/
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
}
