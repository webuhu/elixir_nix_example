{ stdenvNoCC, lib, elixir, MIX_HOME, MIX_REBAR3, MIX_ENV, LANG, mix_deps, mix_build, hash ? null }:

stdenvNoCC.mkDerivation rec {
  __noChroot = if hash == null then true else false;
  name = "mix_docs";
  lib = ../lib;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  inherit MIX_HOME MIX_REBAR3 MIX_ENV LANG mix_deps mix_build;
  buildInputs = [
    elixir
  ];
  # In case you have ExDoc :extras, you'll need to add theme here!
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    # fix double paths in ERL_LIBS caused by Nix Elixir build
    unset ERL_LIBS

    ln -s $lib lib
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    cp -r $mix_build/. _build/
    chmod -R 700 _build

    mkdir $out
    mix docs --output $out
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
}
