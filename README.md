# nix-custom-pkgs

Personal collection of custom nix packages and overlays for my [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager) setup.

Everything here exists because I needed something that wasn't available or working in nixpkgs - patches not yet merged or implemented workarounds and minor build modifications.

## Packages

### `dfu-util`

Device firmware update (DFU) USB programmer. Built from upstream git rather than the nixpkgs release to pick up unreleased code.

- `fast` mode enabled by default so tools like QMK don't need the `:fast` flag.
- Pinned at [`f9a537c`](https://sourceforge.net/p/dfu-util/dfu-util/ci/f9a537c93935d9d536b5ea29b54a226160b2b111/) (2025-03-02).

### `stm32cubeprogrammer`

All-in-one multi-OS software tool for programming STM32 products. Built from the ST installer zip, based on and modified from [this comment](https://github.com/NixOS/nixpkgs/issues/355181#issuecomment-3595404667).

Note: uses `requireFile`, so you must download [`SetupSTM32CubeProgrammer_linux_64.zip`](https://www.st.com/en/development-tools/stm32cubeprog.html) and add it to the Nix store before building.

## Overlays

### `additions`

Loads all packages from `pkgs/` into nixpkgs. Makes `dfu-util` and `stm32cubeprogrammer` available under `pkgs`.

### `modifications`

Overrides a few nixpkgs packages with tweaks I need:

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
nix build github:jyap808/nix-custom-pkgs#stm32cubeprogrammer
```

## License

MIT - Copyright (c) 2026 Julian Yap
