{ stdenvNoCC, lib, elixir, MIX_HOME, MIX_REBAR3, MIX_ENV, LANG, mix_deps, mix_build, release_name, nodejs, node_modules, hash ? null }:

stdenvNoCC.mkDerivation rec {
  __noChroot = if hash == null then true else false;
  name = "mix_release";
  assets = ../assets;
  config = ../config;
  priv = ../priv;
  rel = ../rel;
  mix_exs = ../mix.exs;
  mix_lock = ../mix.lock;
  inherit MIX_ENV MIX_HOME MIX_REBAR3 LANG mix_deps mix_build release_name node_modules;
  buildInputs = [
    elixir
    nodejs
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    ln -s $config config
    ln -s $rel rel
    ln -s $mix_exs mix.exs
    ln -s $mix_lock mix.lock

    cp -r $mix_build/. _build/
    chmod -R 700 _build

    cp -r $mix_deps/. deps/
    chmod -R 700 deps

    cp -r $assets/. assets/
    chmod -R 700 assets

    cp -r $node_modules/. assets/node_modules/

    cp -r $priv/. priv/
    chmod -R 700 priv
 
    npm run deploy --prefix ./assets
    mix phx.digest

    mkdir $out
    mix release $release_name --no-compile --path $out --quiet
  '';

  outputHashMode = "recursive";
  outputHash = hash;

  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
}
