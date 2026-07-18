{
  lib,
  libcec,
  libcec_platform,
  mkKdeDerivation,
  pkg-config,
  plasma-workspace,
  qtwebengine,
  sdl3,
}:

mkKdeDerivation {
  pname = "plasma-bigscreen";

  postPatch = ''
    substituteInPlace bin/plasma-bigscreen-wayland.in \
      --replace-fail @KDE_INSTALL_FULL_LIBEXECDIR@ "${plasma-workspace}/libexec"

    substituteInPlace bin/plasma-bigscreen-wayland.desktop.cmake \
      --replace-fail @CMAKE_INSTALL_FULL_LIBEXECDIR@ "${plasma-workspace}/libexec"
  '';

  dontQmlLint = true;

  extraBuildInputs = [
    qtwebengine

    libcec
    libcec_platform
    sdl3
  ];

  extraCmakeFlags = [
    (lib.cmakeBool "QT_FIND_PRIVATE_MODULES" true)
  ];

  extraNativeBuildInputs = [
    pkg-config
  ];

  passthru.providedSessions = [ "plasma-bigscreen-wayland" ];
}
