{ stdenvNoCC, erlang }:

stdenvNoCC.mkDerivation rec {
  pname = "rebar3";
  version = "3.15.1";
  # How to obtain hash:
  # nix-prefetch-url https://github.com/erlang/rebar3/releases/download/<version>/rebar3
  hash = "sha256:1kqkx1kz3rygjb6292hpm2q4hjf0dpdyhamnzd8dxk155wk9zn5f";
  src = import <nix/fetchurl.nix> {
    url = "https://github.com/erlang/rebar3/releases/download/${version}/rebar3";
    inherit hash;
  };
  buildInputs = [
    erlang
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    mkdir -p $out/bin
    cp $src $out/bin/rebar3
    chmod +x $out/bin/rebar3
    patchShebangs $out/bin/rebar3
  '';
}
