{
  description = "Main flake";

  nixConfig.bash-prompt = "\\e[0;32m[nix-develop@\\h] \\W>\\e[m ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      LANG = "C.UTF-8";
      root = ./.;
    in {
      packages.x86_64-linux.erlang = pkgs.beam.interpreters.erlangR24;
      packages.x86_64-linux.elixir = pkgs.beam.packages.erlangR24.elixir_1_12;
      packages.x86_64-linux.nodejs = pkgs.nodejs-17_x;

      # This is opinionated instead of simple using:
      # pkgs.beam.packages.erlang.hex;
      packages.x86_64-linux.hex = pkgs.callPackage ./pkg/hex.nix {
        inherit (self.packages.x86_64-linux.elixir) LANG;
      };

      # This is opinionated instead of simple using:
      # pkgs.beam.packages.erlang.rebar3;
      packages.x86_64-linux.rebar3 = pkgs.callPackage ./pkg/rebar3.nix {
        inherit (self.packages.x86_64-linux.erlang);
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.elixir;

      postgresql_setup = import ./pkg/temporary_postgresql_db.nix {};

      devShell.x86_64-linux = pkgs.mkShell {
        # Hex
        MIX_PATH = "${self.packages.x86_64-linux.hex}/archives/hex-${self.packages.x86_64-linux.hex.version}/hex-${self.packages.x86_64-linux.hex.version}/ebin";
        HEX_HOME = ".cache/hex";
        # Rebar3
        MIX_REBAR3 = "${self.packages.x86_64-linux.rebar3}/bin/rebar3";
        # enable IEx shell history
        ERL_AFLAGS = "-kernel shell_history enabled";
        packages = [
          self.packages.x86_64-linux.elixir
          self.packages.x86_64-linux.nodejs
          pkgs.inotify-tools
          pkgs.postgresql_14
          pkgs.nixpkgs-fmt
        ];
        shellHook = postgresql_setup;
      };

      checks.x86_64-linux = {
        format = pkgs.runCommandLocal "check-formatted"
          {
            inherit LANG;
            MIX_PATH = "${self.packages.x86_64-linux.hex}/archives/hex-${self.packages.x86_64-linux.hex.version}/hex-${self.packages.x86_64-linux.hex.version}/ebin";
            nativeBuildInputs = [
              self.packages.x86_64-linux.elixir
              pkgs.nixpkgs-fmt
            ];
          } ''
          cd ${root}

          nixpkgs-fmt --check *.nix
          nixpkgs-fmt --check ./pkg/*.nix
          touch $out

          # TODO: Not working
          # export MIX_HOME=.
          # mix format --check-formatted
        '';
      };
    };
}
