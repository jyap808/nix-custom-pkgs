# https://github.com/NixOS/nixpkgs/issues/355181#issuecomment-3595404667
{ lib, stdenv, requireFile, autoPatchelfHook, unzip, openjdk, writeShellScript, buildFHSEnv, libusb1, glib, libz, libkrb5, openssl, libx11, icoutils, qt6Packages, gtk3, pcsclite, wrapGAppsHook3, makeWrapper, copyDesktopItems, makeDesktopItem}:

let
  pname = "stm32cubeprog";
  version = "2.23.0";
  jdk = openjdk.override (
    lib.optionalAttrs stdenv.hostPlatform.isLinux {
      enableJavaFX = true;
    }
  );
in
stdenv.mkDerivation {
  inherit version pname;

  src = requireFile rec {
    name = "SetupSTM32CubeProgrammer_linux_64.zip";
    url = "https://www.st.com/en/development-tools/stm32cubeprog.html";
    sha256 = "0aj4cxhzqnf0imb44bpv340vsv1fvimvd6qz4jrmxi28l2jn17ka";
  };

  nativeBuildInputs = [
    jdk
    unzip
    qt6Packages.wrapQtAppsHook
    wrapGAppsHook3
    copyDesktopItems
    autoPatchelfHook
    icoutils
  ];

  buildInputs = [
    jdk
    libusb1
    glib
    libz
    libkrb5
    openssl
    pcsclite
    libx11
    qt6Packages.qtbase
    qt6Packages.qtserialport
    qt6Packages.qtwayland
    gtk3
  ];

  unpackCmd = ''
    unzip -d stm32cubeprg $curSrc SetupSTM32CubeProgrammer-${version}.exe
    mkdir -p stm32cubeprg/jre/bin
    touch stm32cubeprg/jre/bin/java
  '';

  dontWrapGApps = true;

  postFixup = ''
    wrapGApp $out/bin/${pname}
  '';

  installPhase =
    let
      installEnv = buildFHSEnv {
        name = "installer-env";
        targetPkgs = pkgs: with pkgs; [ jdk ];
        runScript = "java";
      };
    in
    ''
      runHook preInstall

      ${installEnv}/bin/${installEnv.name} -jar -DINSTALL_PATH=stm32cubeprg SetupSTM32CubeProgrammer-${version}.exe -options-system
      rm -r stm32cubeprg/bin/jre

      mkdir $out
      mv ./stm32cubeprg/* $out

      mkdir newjar
      cd newjar
      jar -xf $out/bin/STM32CubeProgrammerLauncher
      jar -cfm $out/bin/STM32CubeProgrammerLauncher META-INF/MANIFEST.MF .
      cd ..

      mkdir icons/
      icotool -x $out/util/Programmer.ico -o icons/
      cd icons/
      ls | awk -v prefix=$out/share/icons/hicolor/ -F'[_x.]' '{ dest=prefix $3 "x" $4; print "mkdir -p " dest "/apps/ && mv " $0 " " dest "/apps/" "${pname}" "." $NF}' | bash
      cd ..

      # Skip udev rules - conflicts with stlink package which provides the same rules
      # rm -rf $out/Drivers/rules

      # CLI tools are already ELF executables that invoke Java internally
      # Just preserve them as-is; the .exe suffix is from the installer
      mv $out/bin/STM32_Programmer_CLI $out/bin/STM32_Programmer_CLI.exe
      mv $out/bin/STM32_SigningTool_CLI $out/bin/STM32_SigningTool_CLI.exe
      mv $out/bin/STM32_KeyGen_CLI $out/bin/STM32_KeyGen_CLI.exe

      # Create simple shell script wrappers that execute the ELF binaries directly
      cat > $out/bin/STM32_Programmer_CLI << EOF
#!/bin/sh
exec $out/bin/STM32_Programmer_CLI.exe "\$@"
EOF
      chmod +x $out/bin/STM32_Programmer_CLI

      cat > $out/bin/STM32_SigningTool_CLI << EOF
#!/bin/sh
exec $out/bin/STM32_SigningTool_CLI.exe "\$@"
EOF
      chmod +x $out/bin/STM32_SigningTool_CLI

      cat > $out/bin/STM32_KeyGen_CLI << EOF
#!/bin/sh
exec $out/bin/STM32_KeyGen_CLI.exe "\$@"
EOF
      chmod +x $out/bin/STM32_KeyGen_CLI

      makeWrapper ${installEnv}/bin/${installEnv.name} $out/bin/${pname} --add-flags "-jar $out/bin/STM32CubeProgrammerLauncher"

      runHook postInstall
    '';

  autoPatchelfIgnoreMissingDeps = [
    "libSTLinkUSBDriver.so"
    "libhsmp11.so"
    "libcrypto.so.1.0.0"
    "libQt5Core.so.5"
    "libQt6WaylandEglClientHwIntegration.so.6"
  ];

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      icon = pname;
      desktopName = "STM32CubeProgrammer";
      comment = "All-in-one multi-OS software tool for programming STM32 products";
      exec = pname;
      categories = [ "Development" ];
    })
  ];

  meta = with lib; {
    description = "All-in-one multi-OS software tool for programming STM32 products";
    longDescription = ''
      STM32CubeProgrammer (STM32CubeProg) is an all-in-one multi-OS
      software tool for programming STM32 products.
      It provides an easy-to-use and efficient environment for reading,
      writing, and verifying device memory through both the debug interface
      (JTAG and SWD)and the bootloader interface (UART and USB DFU, I2C, SPI, and CAN).
      STM32CubeProgrammer offers a wide range of features to program STM32 internal memories
      (such as flash, RAM, and OTP) as well as external memories.
      STM32CubeProgrammer also allows option programming and upload,
      programming content verification, and programming automation through scripting.
    '';
    homepage = "https://www.st.com/en/development-tools/stm32cubeprog.html";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
