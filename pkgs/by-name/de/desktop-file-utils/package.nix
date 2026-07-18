{
  lib,
  stdenv,
  fetchurl,
  glib,
  libintl,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "desktop-file-utils";
  version = "0.28";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/desktop-file-utils/releases/desktop-file-utils-${finalAttrs.version}.tar.xz";
    hash = "sha256-RAHU4jHYQsLegkI5WnSjlcpGjNlvX2ENgi3zNZSJinA=";
  };

  postPatch = ''
    substituteInPlace src/install.c \
      --replace \"update-desktop-database\" \"$out/bin/update-desktop-database\"
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    glib
    libintl
  ];

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Command line utilities for working with .desktop files";
    homepage = "https://www.freedesktop.org/wiki/Software/desktop-file-utils";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin ++ lib.platforms.freebsd;
  };
})
