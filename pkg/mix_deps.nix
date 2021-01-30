{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, MIX_ENV, LANG, hash ? null }:

stdenvNoCC.mkDerivation rec {
  __noChroot = if hash == null then true else false;
  name = "mix_deps";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  inherit MIX_HOME MIX_REBAR3 MIX_ENV LANG;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $config config
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    export HEX_HOME=$TMPDIR/hex
    export MIX_DEPS_PATH=$out
    MIX_QUIET=true mix deps.get --only $MIX_ENV --no-archives-check
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars;
}
