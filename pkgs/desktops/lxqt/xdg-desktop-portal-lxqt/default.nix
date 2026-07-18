{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  kwindowsystem,
  libexif,
  libfm-qt,
  lxqt-qtplugin,
  menu-cache,
  qtbase,
  wrapQtAppsHook,
  extraQtStyles ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-lxqt";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "xdg-desktop-portal-lxqt";
    tag = finalAttrs.version;
    hash = "sha256-GtpOBnRa10xFpd0FHWJge9RtS58hdOawFQmDH6yD1yU=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    kwindowsystem
    libexif
    libfm-qt
    lxqt-qtplugin
    menu-cache
    qtbase
  ]
  ++ extraQtStyles;

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Backend implementation for xdg-desktop-portal that is using Qt/KF5/libfm-qt";
    homepage = "https://github.com/lxqt/xdg-desktop-portal-lxqt";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
