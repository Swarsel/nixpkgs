{
  lib,
  stdenv,
  fetchurl,
  acl,
  autoreconfHook,
  dbus,
  glib,
  jansson,
  libdrm,
  libgudev,
  libusb1,
  libxext,
  libxrandr,
  pkg-config,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ddcutil";
  version = "2.2.7";

  src = fetchurl {
    url = "https://www.ddcutil.com/tarballs/ddcutil-${finalAttrs.version}.tar.gz";
    hash = "sha256-GaxmBM8Rd7pWZm+KaCWB5x6Jc70Gx8jc8DNnTkqqpkg=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    acl
    dbus
    glib
    jansson
    libdrm
    libgudev
    libusb1
    libxext
    libxrandr
    udev
  ];

  doInstallCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "Query and change Linux monitor settings using DDC/CI and USB";
    homepage = "http://www.ddcutil.com/";
    changelog = "https://github.com/rockowitz/ddcutil/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.linux;
    mainProgram = "ddcutil";
  };
})
