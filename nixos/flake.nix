{
  description = "Nodix";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };

  outputs = {home-manager, nixpkgs, ...} @ inputs: {
    nixosConfigurations = {
      nix = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs; };
              overwriteBackup = true;
              useGlobalPkgs = true;
              useUserPackages = true;
              users.junior = ./home.nix;
            };
          }
        ];
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
      };
    };
  };
}
