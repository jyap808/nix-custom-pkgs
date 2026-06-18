# nix-custom-pkgs

Personal collection of custom nix packages and overlays for my [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager) setup.

Everything here exists because I needed something that wasn't available or working in nixpkgs - patches not yet merged or implemented workarounds and minor build modifications.

## Home Manager Modules

### `freecad-gsettings`

Sets `xdg.systemDirs.data` so FreeCAD can find gtk3 gsettings schemas. Workaround for [nixpkgs#463087](https://github.com/NixOS/nixpkgs/issues/463087).

```nix
imports = [ inputs.custom-pkgs.hmModules.freecad-gsettings ];
```

## Packages

### `dfu-util`

Device firmware update (DFU) USB programmer. Built from upstream git rather than the nixpkgs release to pick up unreleased code.

- `fast` mode enabled by default so tools like QMK don't need the `:fast` flag.
- Pinned at `f9a537c` (2025-03-02).

### `vcv-rack`

An open-source virtual modular synthesizer. The nixpkgs version had a build failure because the original patch URL 404ed. This custom version uses the commit hash URL instead. See [nixpkgs#527168](https://github.com/NixOS/nixpkgs/issues/527168) / [nixpkgs#526617](https://github.com/NixOS/nixpkgs/pull/526617).

## Overlays

### `additions`

Loads all packages from `pkgs/` into nixpkgs. Makes `dfu-util` and `vcv-rack` available under `pkgs`.

### `modifications`

Overrides a few nixpkgs packages with tweaks I need:

- **`freecad`** - Adds `networkx` as an extra Python dependency for the SheetMetal workbench.
- **`kicad-x11`** - Forces the `GDK_BACKEND=x11` environment variable to avoid Wayland rendering issues.
- **`kicad-unstable-x11`** - Same X11 wrapper, but using the latest KiCad from nixpkgs-unstable.

## Usage

### As a flake input

```nix
inputs = {
  custom-pkgs.url = "github:jyap808/nix-custom-pkgs";
};
```

```nix
# Use packages directly
packages = custom-pkgs.packages;

# Or apply overlays to your nixpkgs
nixpkgs.overlays = [
  custom-pkgs.overlays.additions
  custom-pkgs.overlays.modifications
];
```

### Build a package

```bash
nix build github:jyap808/nix-custom-pkgs#dfu-util
nix build github:jyap808/nix-custom-pkgs#vcv-rack
```

## License

MIT - Copyright (c) 2026 Julian Yap
