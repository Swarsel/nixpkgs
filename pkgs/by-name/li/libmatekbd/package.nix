{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk3-x11,
  libxklavier,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmatekbd";
  version = "1.28.0";

  src = fetchFromGitHub {
    owner = "mate-desktop";
    repo = "libmatekbd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6s8JiuXbBWOHxbNSuO8rglzOCRKlQ9fx/GsYYc08GmI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3-x11
    libxklavier
  ];

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  depsBuildBuild = [ pkg-config ];

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
  };

  meta = {
    description = "Keyboard management library for MATE";
    homepage = "https://github.com/mate-desktop/libmatekbd";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
