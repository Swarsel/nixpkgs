{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  qtbase,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "libdbusmenu-lxqt";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "libdbusmenu-lxqt";
    rev = version;
    hash = "sha256-5X73kRUtOYeqBEIw2ctUnwXnWKPHDaoT489yT5nugZw=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Qt implementation of the DBusMenu protocol";
    homepage = "https://github.com/lxqt/libdbusmenu-lxqt";
    license = lib.licenses.lgpl21Plus;
    platforms = with lib.platforms; unix;
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.lxqt ];
  };
}
