{
  lib,
  stdenv,
  fetchurl,
  automake,
  libusb1,
}:
let
  # This package should be updated together with libphidget22extra
  version = "1.23.20250925";
in
stdenv.mkDerivation {
  inherit version;
  pname = "libphidget22";

  src = fetchurl {
    url = "https://www.phidgets.com/downloads/phidget22/libraries/linux/libphidget22/libphidget22-${version}.tar.gz";
    hash = "sha256-/2OgjiuoK3+gJ95tSk809OfMABUtKPN9bb4pVH447Ik=";
  };

  strictDeps = true;
  nativeBuildInputs = [ automake ];
  buildInputs = [ libusb1 ];

  meta = {
    description = "Phidget Inc sensor boards and electronics Library";
    homepage = "https://www.phidgets.com/docs/OS_-_Linux";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
  };
}
