{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libsForQt5,
}:

stdenv.mkDerivation rec {
  pname = "heimer";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "juzzlin";
    repo = "heimer";
    rev = version;
    hash = "sha256-eKnGCYxC3b7qd/g2IMDyZveBg+jvFA9s3tWEGeTPSkU=";
  };

  patches = [
    # Fix the build with CMake 4
    (fetchpatch {
      hash = "sha256-mFzfxxhaJ1jdwfFVo36N66+jzS/scEeray1s75c+T8M=";
      name = "update-Argengine.patch";
      url = "https://github.com/juzzlin/Heimer/commit/76d9e8458038d2da4171be3a58766b84334119e8.patch";
    })
    (fetchpatch {
      hash = "sha256-ZPj5GaM13UsGwJbc0NW0xJd07agZT+g86674i3apqWY=";
      name = "update-SimpleLogger.patch";
      url = "https://github.com/juzzlin/Heimer/commit/75bff37b6ebd02d9f734e70ee4d3c10ec0291e0d.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qttools
    libsForQt5.qtbase
  ];

  meta = {
    description = "Simple cross-platform mind map and note-taking tool written in Qt";
    homepage = "https://github.com/juzzlin/Heimer";
    changelog = "https://github.com/juzzlin/Heimer/blob/${version}/CHANGELOG";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "heimer";
  };
}
