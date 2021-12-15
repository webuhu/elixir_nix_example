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

      erlang = pkgs.beam.interpreters.erlangR24;
      elixir = pkgs.beam.packages.erlangR24.elixir_1_13;
      nodejs = pkgs.nodejs-17_x;

      # This is opinionated instead of simple using:
      # pkgs.beam.packages.erlang.hex;
      hex = pkgs.callPackage ./pkg/hex.nix {
        inherit elixir LANG;
      };
      MIX_PATH = "${hex}/archives/hex-${hex.version}/hex-${hex.version}/ebin";

      # This is opinionated instead of simple using:
      # pkgs.beam.packages.erlang.rebar3;
      rebar3 = pkgs.callPackage ./pkg/rebar3.nix {
        inherit erlang;
      };
      MIX_REBAR3 = "${rebar3}/bin/rebar3";


      postgresql_setup = import ./pkg/temporary_postgresql_db.nix { };
    in
    {
      devShell.x86_64-linux = pkgs.mkShell {
        inherit LANG MIX_PATH MIX_REBAR3;
        # use local HOME to avoid global things
        MIX_HOME = ".cache/mix";
        HEX_HOME = ".cache/hex";
        # enable IEx shell history
        ERL_AFLAGS = "-kernel shell_history enabled";
        packages = [
          elixir
          nodejs
          pkgs.inotify-tools
          pkgs.postgresql_14
          pkgs.nixpkgs-fmt
        ];
        shellHook = postgresql_setup;
      };

      checks.x86_64-linux = {
        format = pkgs.runCommandLocal "check-formatted"
          {
            inherit LANG MIX_PATH;
            nativeBuildInputs = [
              elixir
              pkgs.nixpkgs-fmt
            ];
          } ''
          cd ${root}

          nixpkgs-fmt *.nix --check
          nixpkgs-fmt ./pkg/*.nix --check
          touch $out

          # WIP
          # mix format --check-formatted
        '';
      };
    };
}
