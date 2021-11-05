{
  description = "Main flake";

  nixConfig.bash-prompt = "\\e[0;32m[nix-develop@\\h] \\W>\\e[m ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in rec {
      packages.x86_64-linux.erlang = pkgs.beam.interpreters.erlangR24;
      packages.x86_64-linux.elixir = pkgs.beam.packages.erlangR24.elixir_1_12;
      packages.x86_64-linux.nodejs = pkgs.nodejs-17_x;

      # This is opinionated instead of simple using:
      # pkgs.beam.packages.erlang.hex;
      packages.x86_64-linux.hex = pkgs.callPackage ./pkg/hex.nix {
        inherit (self.packages.x86_64-linux.elixir);
      };

      # This is opinionated instead of simple using:
      # pkgs.beam.packages.erlang.rebar3;
      packages.x86_64-linux.rebar3 = pkgs.callPackage ./pkg/rebar3.nix {
        inherit (self.packages.x86_64-linux.erlang);
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.elixir;

      MIX_HOME = self.packages.x86_64-linux.hex;
      MIX_REBAR3 = "${self.packages.x86_64-linux.rebar3}/bin/rebar3";

      postgresql_setup = import ./pkg/temporary_postgresql_db.nix {};
      
      devShell.x86_64-linux = pkgs.mkShell {
        inherit MIX_HOME MIX_REBAR3;
        HEX_HOME = ".cache/hex";
        buildInputs = [
          self.packages.x86_64-linux.elixir
          self.packages.x86_64-linux.nodejs
          pkgs.inotify-tools
          pkgs.postgresql_14
        ];
        shellHook = ''
          # enable IEx shell history
          export ERL_AFLAGS="-kernel shell_history enabled"
        '' + postgresql_setup;
      };
    };
}
