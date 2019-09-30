{ pkgs, elixir, hex, elixir_prepare, MIX_ENV, MIX_REBAR3, LANG }:

rec {
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

  build = pkgs.stdenv.mkDerivation rec {
    name = "docs";
    lib = ../lib;
    mix_exs = ../mix.exs;
    mix_lock = ../mix.lock;
    readme = ../README.md;
    inherit prepare elixir_prepare MIX_ENV MIX_REBAR3 LANG;
    nativeBuildInputs = [elixir hex];
    builder = builtins.toFile "builder.sh" ''
      source $stdenv/setup

      ln -s $lib lib
      ln -s $mix_exs mix.exs
      ln -s $mix_lock mix.lock
      ln -s $readme README.md

      ${elixir_import_deps}
      ${elixir_import_build}

      mix docs
      mkdir $out
      cp -r ./doc/. $out/
    '';
  };
}
