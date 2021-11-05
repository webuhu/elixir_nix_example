{ stdenvNoCC, elixir }:

stdenvNoCC.mkDerivation rec {
  pname = "hex";
  version = "0.21.3";
  elixir_version = "1.12.0";
  # How to obtain hash:
  # nix-prefetch-url https://repo.hex.pm/installs/<elixir_verion>/hex-<version>.ez
  hash = "sha256:08n51hjjf0b2lrbs48xz21sbda5fsh45c9g9wq0r6lq9qkh3ygb2";
  src = import <nix/fetchurl.nix> {
    url = "https://repo.hex.pm/installs/${elixir_version}/hex-${version}.ez";
    inherit hash;
  };
  buildInputs = [
    elixir
  ];
  builder = builtins.toFile "builder.sh" ''
    source $stdenv/setup

    mkdir $out
    MIX_HOME=$out mix archive.install $src --force
  '';
}
