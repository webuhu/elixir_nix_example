{ pkgs, elixir, LANG }:

pkgs.mkShell {
  inherit LANG;
  nativeBuildInputs = [elixir];
  shellHook = ''
    elixir pkg/scripts/pkgs_update.exs
    echo '--'
    cat pkg/_pkgs.nix
    echo '--'
    echo -e "\e[0;32mpkgs update succeeded\e[m"
    exit
  '';
}
