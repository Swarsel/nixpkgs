{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libusb1,
  pcsclite,
  pkg-config,
}:

let
  version = "3.99.5";
  suffix = "SP15";
  tarBall = "${version}final.${suffix}";

in
stdenv.mkDerivation rec {
  inherit version;
  pname = "pcsc-cyberjack";

  src = fetchurl {
    url = "https://support.reiner-sct.de/downloads/LINUX/V${version}_${suffix}/pcsc-cyberjack_${tarBall}.tar.bz2";
    sha256 = "sha256-rLfCgyRQcYdWcTdnxLPvUAgy1lLtUbNRELkQsR69Rno=";
  };

  outputs = [
    "out"
    "tools"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libusb1
    pcsclite
  ];

  configureFlags = [
    "--with-usbdropdir=${placeholder "out"}/pcsc/drivers"
    "--bindir=${placeholder "tools"}/bin"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=narrowing";
  postInstall = "make -C tools/cjflash install";
  enableParallelBuilding = true;

  meta = {
    description = "REINER SCT cyberJack USB chipcard reader user space driver";
    homepage = "https://www.reiner-sct.com/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      aszlig
      flokli
    ];

    platforms = lib.platforms.linux;
    mainProgram = "cjflash";
  };
}
