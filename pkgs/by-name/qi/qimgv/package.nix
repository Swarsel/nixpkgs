{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  exiv2,
  kdePackages,
  mpv,
  opencv4,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "qimgv";
  version = "1.0.3-unstable-2026-01-19";

  src = fetchFromGitHub {
    owner = "easymodo";
    repo = "qimgv";
    rev = "3127a2d211b124ad4fcf853d01e6df9323bdfdc3";
    sha256 = "sha256-avn02kdMyA5PZUSykxgIk1I78zHQ/WKd26tQO8lMOow=";
  };

  postPatch = ''
    sed -i "s@/usr/bin/mpv@${mpv}/bin/mpv@" \
      qimgv/settings.cpp
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    exiv2
    mpv
    opencv4.cxxdev
    kdePackages.qtbase
    kdePackages.qtimageformats
    kdePackages.qtsvg
    kdePackages.qttools
    kdePackages.kimageformats
    kdePackages.kwindowsystem
  ];

  cmakeFlags = [
    "-DVIDEO_SUPPORT=ON"
    "-DUSE_QT5=OFF"
    "-DKDE_SUPPORT=ON"
  ];

  # Wrap the library path so it can see `libqimgv_player_mpv.so`, which is used
  # to play video files within qimgv itself.
  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${placeholder "out"}/lib"
  ];

  meta = {
    description = "Qt6 image viewer with optional video support";
    homepage = "https://github.com/easymodo/qimgv";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ cole-h ];
    platforms = lib.platforms.linux;
    mainProgram = "qimgv";
  };
}
