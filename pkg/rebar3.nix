{ stdenvNoCC, erlang }:

stdenvNoCC.mkDerivation rec {
  pname = "rebar3";
  # rebar 3.14.x wont work prior Elixir 1.12
  version = "3.13.2";
  # How to obtain hash:
  # nix-prefetch-url https://github.com/erlang/rebar3/releases/download/<version>/rebar3
  hash = "sha256:063h8i15315cmman4i6hd33vj5ydd9qggfww517ys9nyqc5c1n5x";
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
