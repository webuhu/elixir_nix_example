{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, MIX_ENV, LANG, mix_deps, hash }:

stdenvNoCC.mkDerivation rec {
  name = "mix_build";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  chached_mix_build = ../.nix/_build;
  inherit MIX_HOME MIX_REBAR3 MIX_ENV LANG mix_deps;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    # fix double paths in ERL_LIBS caused by Nix Elixir build
    unset ERL_LIBS

    ln -s $config config
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    cp -r $chached_mix_build/. _build/
    chmod -R 700 _build

    mix compile

    mkdir -p $out/$MIX_ENV
    cp -r _build/$MIX_ENV/. $out/$MIX_ENV/
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars;
}
