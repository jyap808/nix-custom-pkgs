{ lib, stdenv, fetchgit, autoreconfHook, pkg-config, libusb1 }:

stdenv.mkDerivation {
  pname = "dfu-util";
  version = "0.11-unstable-2025-03-02";

  src = fetchgit {
    url = "https://git.code.sf.net/p/dfu-util/dfu-util";
    rev = "f9a537c93935d9d536b5ea29b54a226160b2b111";
    hash = "sha256-NlAidDitUkGj9CrImLl/S9g1CSdgoq+xxh88Dx9UQDI=";
  };

  # Build from upstream git (not nixpkgs release tarball) to pull in fixes.
  # Pinned at f9a537c (2025-03-02) - latest master as of 2026-06-10.
  #
  # Enable 'fast' mode by default so tools invoking dfu-util
  # (e.g. QMK) don't need to pass the :fast flag.
  # Fast mode skips DFU poll timeouts to speed up flashing.
  postPatch = ''
    substituteInPlace src/dfuse.c \
      --replace-fail 'static int dfuse_fast = 0;' 'static int dfuse_fast = 1;'
  '';

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ libusb1 ];

  meta = with lib; {
    description = "Device firmware update (DFU) USB programmer";
    longDescription = ''
      dfu-util is a program that implements the host (PC) side of the USB
      DFU 1.0 and 1.1 (Universal Serial Bus Device Firmware Upgrade) protocol.
      DFU is intended to download and upload firmware to devices connected over
      USB. It ranges from small devices like micro-controller boards up to mobile
      phones. With dfu-util you are able to download firmware to your device or
      upload firmware from it.
    '';
    homepage = "https://dfu-util.sourceforge.net";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
