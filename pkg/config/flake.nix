{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11-small";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.elixir-app-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
