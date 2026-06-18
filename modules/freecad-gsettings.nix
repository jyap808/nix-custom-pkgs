{ pkgs, ... }: {
  # Workaround for https://github.com/NixOS/nixpkgs/issues/463087
  # FreeCAD needs gtk3 gsettings schemas in XDG_DATA_DIRS to avoid
  # "GLib-GIO-ERROR: No GSettings schemas are installed on the system"
  xdg.systemDirs.data = [
    "${pkgs.gtk3}/share/gsettings-schemas/gtk+3-${pkgs.gtk3.version}"
  ];
}
