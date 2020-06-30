{ pkgs ? import <nixpkgs> {} }:

with pkgs.beam.packages.erlangR22;
pkgs.mkShell {
  LANG="C.UTF8";
  buildInputs = [elixir_1_10];
}
