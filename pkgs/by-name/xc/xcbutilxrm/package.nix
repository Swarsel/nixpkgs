{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxcb,
  libxcb-util,
  m4,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xcb-util-xrm";
  version = "1.3";

  src = fetchurl {
    url = "https://github.com/Airblader/xcb-util-xrm/releases/download/v${finalAttrs.version}/xcb-util-xrm-${finalAttrs.version}.tar.bz2";
    sha256 = "118cj1ybw86pgw0l5whn9vbg5n5b0ijcpx295mwahzi004vz671h";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    m4
  ];

  buildInputs = [
    libxcb
    libxcb-util
    libx11
  ];

  doCheck = true;

  meta = {
    description = "XCB utility functions for the X resource manager";
    homepage = "https://github.com/Airblader/xcb-util-xrm";
    license = lib.licenses.mit; # X11 variant
    platforms = with lib.platforms; unix;
  };
})
