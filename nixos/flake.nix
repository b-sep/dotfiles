{
  description = "Nodix";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      # Pinado no último commit antes da série de YUV/dmabuf de 2026-11-19,
      # que trava o Hyprland no init do renderer com a NVIDIA 580 (GTX 1070).
      # Ver: 49b566a -> 9927f2e (9 commits). Remover o pin quando corrigido upstream.
      url = "github:hyprwm/Hyprland/49b566a9780413a2498b7e8b925337ddb41a41a7";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    mattpocock-skills = {
      flake = false;
      url = "github:mattpocock/skills";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    openbot = {
      url = "github:nightly-labs/openbot";
      inputs.nixpkgs.follows = "nixpkgs";
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
