{
  description = "Custom nix packages and overlays";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }: let
    systems = [ "x86_64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system:
      import ./pkgs (import nixpkgs { inherit system; })
    );

    overlays = import ./overlays { inputs = { inherit nixpkgs-unstable; }; };

    hmModules = {
      freecad-gsettings = import ./modules/freecad-gsettings.nix;
    };
  };
}
