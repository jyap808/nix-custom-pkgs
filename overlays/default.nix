{inputs, ...}: {
  # Our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final;

  modifications = final: prev: let
    unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.system};

    mkKicadX11 = name: kicadPkg: final.symlinkJoin {
      inherit name;
      paths = [ kicadPkg ];
      nativeBuildInputs = [ final.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kicad --set GDK_BACKEND x11
      '';
    };
  in {
    freecad = prev.freecad.customize {
      pythons = [
        (ps: [ ps.networkx ])
      ];
    };

    kicad-x11 = mkKicadX11 "kicad-x11" prev.kicad;
    kicad-unstable-x11 = mkKicadX11 "kicad-unstable-x11" unstablePkgs.kicad;
  };
}