{ stdenvNoCC, erlang }:

stdenvNoCC.mkDerivation rec {
  pname = "rebar3";
  version = "3.17.0";
  # How to obtain hash:
  # nix-prefetch-url https://github.com/erlang/rebar3/releases/download/<version>/rebar3
  hash = "sha256:10f1v62if9g5l8db9fvxm52h3g9rdprgc5dbzrpp6f6vd9g347rr";
  src = import <nix/fetchurl.nix> {
    url = "https://github.com/erlang/rebar3/releases/download/${version}/rebar3";
    inherit hash;
  };
  nativeBuildInputs = [
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
