{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  kdePackages,
  qt6,
}:

stdenv.mkDerivation {
  pname = "kgeotag";
  version = "1.8.0-unstable-2025-11-01";

  src = fetchFromGitLab {
    owner = "graphics";
    repo = "kgeotag";
    rev = "879418eb57e96beb5be3e3a69d0bab2b666b7c7f";
    hash = "sha256-RFC8UMrURn2vsTRjPFyLNlsep/PWRadkRkS7aFtTlKE=";
    domain = "invent.kde.org";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.libkexiv2
    kdePackages.marble
    qt6.qtwebengine
  ];

  meta = {
    description = "Stand-alone photo geotagging program";
    homepage = "https://kgeotag.kde.org/";
    changelog = "https://invent.kde.org/graphics/kgeotag/-/blob/master/CHANGELOG.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ cimm ];
    mainProgram = "kgeotag";
  };
}
