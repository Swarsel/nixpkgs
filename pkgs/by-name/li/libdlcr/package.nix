{
  lib,
  stdenv,
  cmake,
  fetchzip,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdlcr";
  version = "0.3.0";

  src = fetchzip {
    url = "https://dragnlabs.com/host-tools/dlcr_host_v${finalAttrs.version}.zip";
    hash = "sha256-DOoc02woE10tU+8CDaYC0Xezvma06+UbhVuGFEiG67c=";
    stripRoot = false;
  };

  postPatch = ''
    # Workaround based on
    # https://github.com/NixOS/nixpkgs/issues/144170

    substituteInPlace libdlcr.pc.in --replace-fail "\''${prefix}/" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ libusb1 ];
  __structuredAttrs = true;

  meta = {
    description = "Dragon Labs CR-8 Host Driver and Utilities";
    homepage = "https://dragnlabs.com/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ noderyos ];
    platforms = lib.platforms.unix;
  };
})
