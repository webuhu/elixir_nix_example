{ stdenvNoCC, elixir, LANG }:

stdenvNoCC.mkDerivation rec {
  pname = "hex";
  version = "0.21.1";
  elixir_version = "1.11.0";
  # How to obtain hash:
  # nix-prefetch-url https://repo.hex.pm/installs/<elixir_verion>/hex-<version>.ez
  hash = "sha256:1ipn58h2fzdabdq2iq724dih6i5kfjzzr6r5dxgfskbsnifpdykm";
  src = import <nix/fetchurl.nix> {
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
