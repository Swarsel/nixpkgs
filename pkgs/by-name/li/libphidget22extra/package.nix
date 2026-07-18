{
  lib,
  stdenv,
  fetchurl,
  automake,
  libphidget22,
  libusb1,
}:
let

  # This package should be updated together with libphidget22
  version = "1.23.20250925";
in
stdenv.mkDerivation {
  inherit version;
  pname = "libphidget22extra";

  src = fetchurl {
    url = "https://www.phidgets.com/downloads/phidget22/libraries/linux/libphidget22extra/libphidget22extra-${version}.tar.gz";
    hash = "sha256-eU/4tO9oa+/Cyy2Ro3zm2m3sAN4s3mCcRblicqSapxs=";
  };

  strictDeps = true;
  nativeBuildInputs = [ automake ];

  buildInputs = [
    libphidget22
    libusb1
  ];

  meta = {
    description = "Phidget Inc sensor boards and electronics extras library";
    homepage = "https://www.phidgets.com/docs/OS_-_Linux";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
  };
}
