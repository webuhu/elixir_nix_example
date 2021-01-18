{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, MIX_ENV, LANG, mix_deps, hash ? null }:

stdenvNoCC.mkDerivation rec {
  __noChroot = if hash == null then true else false;
  name = "mix_build";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
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

    mix compile

    mkdir $out
    cp -r _build/$MIX_ENV/. $out/$MIX_ENV/
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars;
}
