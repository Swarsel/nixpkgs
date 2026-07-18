{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  kwindowsystem,
  liblxqt,
  libqtxdg,
  lxqt-build-tools,
  polkit-qt-1,
  qtsvg,
  qttools,
  qtwayland,
  tzdata,
  wrapQtAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "lxqt-admin";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "lxqt";
    repo = "lxqt-admin";
    rev = version;
    hash = "sha256-SNEOqyLIDlOio4LttsCUgC/EnGcCSDTwPxhJo1lEvJE=";
  };

  postPatch = ''
    for f in lxqt-admin-{time,user}/CMakeLists.txt; do
      substituteInPlace $f --replace-fail \
        "\''${POLKITQT-1_POLICY_FILES_INSTALL_DIR}" \
        "$out/share/polkit-1/actions"
    done

    # patch timezone database file location
    substituteInPlace lxqt-admin-time/timeadmindialog.cpp \
      --replace-fail "/usr/share/zoneinfo/zone.tab" "${tzdata}/share/zoneinfo/zone.tab"
  '';

  nativeBuildInputs = [
    cmake
    lxqt-build-tools
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    kwindowsystem
    liblxqt
    libqtxdg
    polkit-qt-1
    qtsvg
    qtwayland
  ];

  cmakeFlags = [
    # fake finding of libsystemd; used to check if we are a systemd-based
    # distro rather than actually being linked to
    "-DLIBSYSTEMD_FOUND=TRUE"
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "LXQt system administration tool";
    homepage = "https://github.com/lxqt/lxqt-admin";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxqt ];
  };
}
