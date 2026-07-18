{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  gtk3,
  libfakekey,
  libwnck,
  libxtst,
  mate-panel,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-netbook";
  version = "1.26.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-netbook-${finalAttrs.version}.tar.xz";
    sha256 = "12gdy69nfysl8vmd8lv8b0lknkaagplrrz88nh6n0rmjkxnipgz3";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libwnck
    libfakekey
    libxtst
    mate-panel
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-netbook";
  };

  meta = {
    description = "MATE utilities for netbooks";

    longDescription = ''
      MATE utilities for netbooks are an applet and a daemon to maximize
      windows and move their titles on the panel.

      Installing these utilities is recommended for netbooks and similar
      devices with low resolution displays.
    '';

    homepage = "https://mate-desktop.org";

    license = with lib.licenses; [
      gpl3Only
      lgpl2Plus
    ];

    platforms = lib.platforms.unix;
    mainProgram = "mate-maximus";
    teams = [ lib.teams.mate ];
  };
})
