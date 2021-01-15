{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, mix_deps, LANG }:

stdenvNoCC.mkDerivation rec {
  name = "mix_build";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  # hash = "sha256:${pkgs.lib.fakeSha256}";
  hash = "sha256:1biszdl3pbyqf7998387khwpr2i94d76hlbdrdg4hzbdyp4k4wll";
  inherit MIX_HOME MIX_REBAR3 mix_deps LANG;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $config config
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    # ln -s $mix_deps deps
    mkdir -p deps
    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    mkdir $out
    export MIX_BUILD_ROOT=$out
    mix compile
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars;
}
