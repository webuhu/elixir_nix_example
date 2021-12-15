{ stdenvNoCC, elixir, LANG }:

stdenvNoCC.mkDerivation rec {
  pname = "hex";
  version = "1.0.1";
  elixir_version = "1.13.0";
  # How to obtain hash:
  # nix-prefetch-url https://repo.hex.pm/installs/<elixir_verion>/hex-<version>.ez
  # nix-prefetch-url https://repo.hex.pm/installs/1.13.0/hex-1.0.1.ez
  hash = "sha256:1ywryrmbpgf8519413pf8099ggicv3r5pbxan9bi9sbwv2393fw4";
  src = import <nix/fetchurl.nix> {
    url = "https://repo.hex.pm/installs/${elixir_version}/hex-${version}.ez";
    inherit hash;
  };
  inherit LANG;
  nativeBuildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    mkdir $out
    MIX_HOME=$out mix archive.install $src --force
  '';
}
