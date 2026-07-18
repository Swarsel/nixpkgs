{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  intltool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxmenu-data";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxmenu-data";
    tag = finalAttrs.version;
    hash = "sha256-JwyJkZIJye8Mtx8yOcpxzOO1Gw0K5ZT00DGgXNqziJQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    pkg-config
    glib
  ];

  meta = {
    description = "Freedesktop.org desktop menus for LXDE";
    homepage = "https://lxde.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
