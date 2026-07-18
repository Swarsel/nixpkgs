{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  libvdpau,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vdpauinfo";
  version = "1.5";

  src = fetchurl {
    url = "https://gitlab.freedesktop.org/vdpau/vdpauinfo/-/archive/${finalAttrs.version}/vdpauinfo-${finalAttrs.version}.tar.bz2";
    hash = "sha256-uOs/r8Ow7KvSpY1NhD2A+D4Qs6iWJe4fZGfVj6nIiCw=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libvdpau ];

  meta = {
    description = "Tool to query the Video Decode and Presentation API for Unix (VDPAU) abilities of the system";
    homepage = "https://people.freedesktop.org/~aplattner/vdpau/";
    license = lib.licenses.mit; # expat version
    maintainers = with lib.maintainers; [ vcunat ];
    platforms = lib.platforms.unix;
    mainProgram = "vdpauinfo";
  };
})
