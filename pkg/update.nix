{ pkgs, elixir, LANG }:

pkgs.mkShell {
  inherit LANG;
  NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  nativeBuildInputs = [elixir pkgs.nix];
  shellHook = ''
    elixir pkg/scripts/pkgs_update.exs
    echo '--'
    cat pkg/_pkgs.nix
    echo '--'
    echo -e "\e[0;32mpkgs update succeeded\e[m"
    exit
  '';
}
