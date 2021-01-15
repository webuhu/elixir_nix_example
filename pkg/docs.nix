{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, LANG, mix_deps }:

stdenvNoCC.mkDerivation rec {
  name = "docs";
  lib = ../lib;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  readme = ../README.md;
  inherit MIX_HOME MIX_REBAR3 LANG mix_deps;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $lib lib
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock
    ln -s $readme README.md

    mkdir -p deps
    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    # import_deps
    # import_build

    mix docs
    mkdir $out
    cp -r ./doc/. $out/
  '';
}
