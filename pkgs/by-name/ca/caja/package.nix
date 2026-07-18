{
  lib,
  stdenv,
  fetchurl,
  exempi,
  fetchpatch,
  gettext,
  gitUpdater,
  gtk-layer-shell,
  gtk3,
  hicolor-icon-theme,
  libexif,
  libnotify,
  libxml2,
  mate-desktop,
  pkg-config,
  wayland,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "caja";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/caja-${finalAttrs.version}.tar.xz";
    sha256 = "HjAUzhRVgX7C73TQnv37aDXYo3LtmhbvtZGe97ghlXo=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # wayland: ensure windows can be moved if compositor is using CSD
    # https://github.com/mate-desktop/caja/pull/1787
    (fetchpatch {
      hash = "sha256-2QAXveJnrPPyFSBST6wQcXz9PRsJVdt4iSYy0gubDAs=";
      url = "https://github.com/mate-desktop/caja/commit/b0fb727c62ef9f45865d5d7974df7b79bcf0d133.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk-layer-shell
    gtk3
    libnotify
    libxml2
    libexif
    exempi
    mate-desktop
    hicolor-icon-theme
    wayland
  ];

  configureFlags = [ "--disable-update-mimedb" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/caja";
  };

  meta = {
    description = "File manager for the MATE desktop";
    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
