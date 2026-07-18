{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libusb-compat-0_1,
  pcsclite,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "libacr38u";
  version = "1.7.11";

  src = fetchurl {
    url = "http://http.debian.net/debian/pool/main/a/acr38/acr38_1.7.11.orig.tar.bz2";
    sha256 = "0lxbq17y51cablx6bcd89klwnyigvkz0rsf9nps1a97ggnllyzkx";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    pcsclite
    libusb-compat-0_1
  ];

  preBuild = ''
    makeFlagsArray=(usbdropdir="$out/pcsc/drivers");
  '';

  doCheck = true;

  meta = {
    description = "ACR38U smartcard reader driver for pcsclite";

    longDescription = ''
      A PC/SC IFD handler implementation for the ACS ACR38U
      smartcard readers. This driver is for the non-CCID version only.

      This package is needed to communicate with the ACR38U smartcard readers through
      the PC/SC Lite resource manager (pcscd).

      It can be enabled in /etc/nixos/configuration.nix by adding:
        services.pcscd.enable = true;
        services.pcscd.plugins = [ libacr38u ];

      The package is based on the debian package libacr38u.
    '';

    homepage = "https://www.acs.com.hk";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
}
