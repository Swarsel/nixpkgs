{
  lib,
  stdenv,
  fetchurl,
  gettext,
  gitUpdater,
  gtkmm3,
  itstool,
  libgtop,
  librsvg,
  libxml2,
  mate-desktop,
  pkg-config,
  polkit,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-system-monitor";
  version = "1.28.1";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-system-monitor-${finalAttrs.version}.tar.xz";
    sha256 = "QtZj1rkPtTYevBP2VHmD1vHirHXcKuTxysbqYymWWiU=";
  };

  postPatch = ''
    # This package does not provide mate-version.xml.
    substituteInPlace src/sysinfo.cpp \
      --replace-fail 'DATADIR "/mate-about/mate-version.xml"' '"${mate-desktop}/share/mate-about/mate-version.xml"'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    gettext
    itstool
    libxml2 # xmllint
    wrapGAppsHook3
  ];

  buildInputs = [
    gtkmm3
    libxml2
    libgtop
    librsvg
    polkit
    systemd
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-system-monitor";
  };

  meta = {
    description = "System monitor for the MATE desktop";
    homepage = "https://mate-desktop.org";
    license = [ lib.licenses.gpl2Plus ];
    platforms = lib.platforms.unix;
    mainProgram = "mate-system-monitor";
    teams = [ lib.teams.mate ];
  };
})
