{
  lib,
  stdenv,
  linux,
}:

stdenv.mkDerivation {
  inherit (linux) src;
  pname = "gpio-utils";
  version = linux.version;

  makeFlags = linux.commonMakeFlags ++ [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  preConfigure = ''
    cd tools/gpio
  '';

  installFlags = [
    "install"
    "DESTDIR=$(out)"
    "bindir=/bin"
  ];

  separateDebugInfo = true;

  meta = {
    description = "Linux tools to inspect the gpiochip interface";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ kwohlfahrt ];
    platforms = lib.platforms.linux;
  };
}
