{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, LANG, env ? "prod" }:

let
  MIX_ENV = env;

in stdenvNoCC.mkDerivation rec {
  name = "mix_deps";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  # hash = "sha256:${pkgs.lib.fakeSha256}";
  hash = "sha256:1biszdl3pbyqf7998387khwpr2i94d76hlbdrdg4hzbdyp4k4wll";
  inherit MIX_HOME MIX_REBAR3 LANG;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    export HEX_HOME=$TMPDIR/hex

    ln -s $config config
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    mkdir $out
    export MIX_DEPS_PATH=$out
    MIX_QUIET=true mix deps.get
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars;
}
