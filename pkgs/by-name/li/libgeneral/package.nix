{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  avahi,
  clangStdenv,
  libimobiledevice,
  libusb1,
  pkg-config,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "libgeneral";
  version = "90";

  src = fetchFromGitHub {
    owner = "tihmstar";
    repo = "libgeneral";
    tag = finalAttrs.version;
    hash = "sha256-/IVh+XwUAok3RnTuQ6HuOR+GeBOAXX27xpdXWp3ISRI=";
  };

  # Do not depend on git to calculate version, instead
  # pass version via configureFlag
  patches = [ ./configure-version.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  configureFlags = [
    "--with-version-commit-count=${finalAttrs.version}"
  ];

  meta = {
    description = "Helper library used by usbmuxd2";
    homepage = "https://github.com/tihmstar/libgeneral";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.all;
  };
})
