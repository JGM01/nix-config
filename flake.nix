{
  description = "trollserver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
		nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { self, nixpkgs, agenix, nix-minecraft }@inputs:
    {
      nixosConfigurations.trollserver =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

					specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
	    			agenix.nixosModules.default
          ];
        };
    };
}
