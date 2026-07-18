{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  mate-common,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-menus";
  version = "1.28.1";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "mate-menus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GAc9DPsXdswmyNKlbY6cyHBWO2OSKCBygtzttNHN/p4=";
  };

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    pkg-config
    gettext
    gobject-introspection
    mate-common # mate-common.m4 macros
  ];

  buildInputs = [
    glib
    python3
  ];

  makeFlags = [
    "INTROSPECTION_GIRDIR=$(out)/share/gir-1.0/"
    "INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository-1.0"
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-menus";
  };

  meta = {
    description = "Menu system for MATE";
    homepage = "https://github.com/mate-desktop/mate-menus";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.mate ];
  };
})
