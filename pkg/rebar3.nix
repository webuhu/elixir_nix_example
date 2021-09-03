{ stdenvNoCC, fetchurl, erlang }:

stdenvNoCC.mkDerivation rec {
  pname = "rebar3";
  version = "3.16.1";
  # How to obtain hash:
  # nix-prefetch-url https://github.com/erlang/rebar3/releases/download/<version>/rebar3
  hash = "sha256:1pcb2cgq6jlxxv28bq5c1cap7mq1wsvc2dqzjj3b5fz9n2k67jqp";
  src = fetchurl {
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
