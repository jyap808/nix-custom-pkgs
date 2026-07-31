# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  dfu-util = pkgs.callPackage ./dfu-util.nix { };
  stm32cubeprogrammer = pkgs.callPackage ./stm32cubeprogrammer.nix { };
  vcv-rack = pkgs.callPackage ./vcv-rack.nix { };
}