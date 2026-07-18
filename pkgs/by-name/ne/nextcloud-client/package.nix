{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  inotify-tools,
  kdePackages,
  kdsingleapplication,
  libcloudproviders,
  libp11,
  librsvg,
  libsecret,
  libsysprof-capture,
  openssl,
  pcre2,
  pkg-config,
  qt6Packages,
  sphinx,
  sqlite,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nextcloud-client";
  version = "33.0.7";

  src = fetchFromGitHub {
    owner = "nextcloud-releases";
    repo = "desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hfATh24U9o2ZifB1UlLu893aENILb9a/j/IvIytIR5s=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-When-creating-the-autostart-entry-do-not-use-an-abso.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '"''${SYSTEMD_USER_UNIT_DIR}"' "\"$out/lib/systemd/user\""

    for file in src/libsync/vfs/*/CMakeLists.txt; do
      substituteInPlace $file \
        --replace-fail "PLUGINDIR" "KDE_INSTALL_PLUGINDIR"
    done
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
    kdePackages.extra-cmake-modules
    librsvg
    sphinx
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    inotify-tools
    kdePackages.kio
    kdsingleapplication
    libcloudproviders
    libp11
    libsecret
    openssl
    pcre2
    qt6Packages.qt5compat
    qt6Packages.qtbase
    qt6Packages.qtkeychain
    qt6Packages.qtsvg
    qt6Packages.qttools
    qt6Packages.qtwebengine
    qt6Packages.qtwebsockets
    qt6Packages.qtwayland
    sqlite
    libsysprof-capture
  ];

  cmakeFlags = [
    "-DBUILD_UPDATER=off"
    "-DCMAKE_INSTALL_LIBDIR=lib" # expected to be prefix-relative by build code setting RPATH
    "-DMIRALL_VERSION_SUFFIX=" # remove git suffix from version
  ];

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libsecret ]}"
    # make xdg-open overridable at runtime
    "--suffix PATH : ${lib.makeBinPath [ xdg-utils ]}"
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Desktop sync client for Nextcloud";
    homepage = "https://nextcloud.com";
    changelog = "https://github.com/nextcloud/desktop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      SuperSandro2000
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nextcloud";
  };
})
