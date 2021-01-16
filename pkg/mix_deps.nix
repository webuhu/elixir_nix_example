{ stdenvNoCC, elixir, MIX_HOME, MIX_REBAR3, MIX_ENV, LANG, hash }:

stdenvNoCC.mkDerivation rec {
  name = "mix_deps";
  config = ../config;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  cached_mix_deps = ../.nix/deps;
  inherit MIX_HOME MIX_REBAR3 MIX_ENV LANG;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    export HEX_HOME=$TMPDIR/hex

    ln -s $config config
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $cached_mix_deps/. deps/

    export MIX_QUIET=true

    # clean unused deps in current env (MIX_ENV)
    mix deps.clean --unused --only $MIX_ENV

    mix deps.get --only $MIX_ENV --no-archives-check

    mkdir $out
    cp -r deps/. $out/
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars;
}
