{ stdenvNoCC, erlang }:

stdenvNoCC.mkDerivation rec {
  pname = "rebar3";
  version = "3.16.0";
  # How to obtain hash:
  # nix-prefetch-url https://github.com/erlang/rebar3/releases/download/<version>/rebar3
  hash = "sha256:1jyknwjl9bb04klhfphs79sc4nj7c2ysx5w9821a2pr5jj7cayrp";
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
