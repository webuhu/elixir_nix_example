{ stdenvNoCC, fetchurl, elixir, LANG }:

stdenvNoCC.mkDerivation rec {
  pname = "hex";
  version = "0.21.2";
  elixir_version = "1.11.0";
  # How to obtain hash:
  # nix-prefetch-url https://repo.hex.pm/installs/<elixir_verion>/hex-<version>.ez
  hash = "sha256:0cdx2xv2qpv7a77j1b8xmiiapv0y8vsb3q2r06g73bxj5gwgcipm";
  src = fetchurl {
    url = "https://repo.hex.pm/installs/${elixir_version}/hex-${version}.ez";
    inherit hash;
  };
  inherit LANG;
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    mkdir $out
    MIX_HOME=$out mix archive.install $src --force
  '';
}
