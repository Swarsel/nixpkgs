{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  boost,
  chromaprint,
  cmake,
  config,
  elfutils,
  fftw,
  gettext,
  glew,
  gst_all_1,
  gvfs,
  libcdio,
  libgpod,
  libmtp,
  libplist,
  libpulseaudio,
  libsForQt5,
  libselinux,
  libsepol,
  libunwind,
  orc,
  pkg-config,
  projectm_3,
  protobuf,
  qt5,
  sparsehash,
  sqlite,
  taglib_1,
  usbmuxd,
  util-linuxMinimal,
}:

let
  withIpod = config.clementine.ipod or false;
  withMTP = config.clementine.mtp or true;
  withCD = config.clementine.cd or true;
  withCloud = config.clementine.cloud or true;

  gst_plugins = with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gst-libav
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "clementine";
  version = "1.4.1-60-g1a3e8b56f";

  src = fetchFromGitHub {
    owner = "clementine-player";
    repo = "Clementine";
    tag = finalAttrs.version;
    hash = "sha256-FRgTi1Qxzp0vJASNpyANqh4rJX4caxEr0CZOnTHA3Kw=";
  };

  postPatch = ''
    sed -i src/CMakeLists.txt \
      -e 's,-Werror,,g' \
      -e 's,-Wno-unknown-warning-option,,g' \
      -e 's,-Wno-unused-private-field,,g'
    sed -i CMakeLists.txt \
      -e 's,libprotobuf.a,protobuf,g'

    # CMake 3.0.0 is deprecated and no longer supported by CMake > 4
    # https://github.com/NixOS/nixpkgs/issues/445447
    substituteInPlace 3rdparty/{qsqlite,qtsingleapplication,qtiocompressor,qxt}/CMakeLists.txt \
      cmake/{ParseArguments.cmake,Translations.cmake}                                          \
      tests/CMakeLists.txt gst/moodbar/CMakeLists.txt                                          \
      --replace-fail                                                                           \
        "cmake_minimum_required(VERSION 3.0.0)" \
        "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace 3rdparty/libmygpo-qt5/CMakeLists.txt --replace-fail \
      "cmake_minimum_required( VERSION 3.0.0 FATAL_ERROR )" \
      "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace CMakeLists.txt --replace-fail \
        "cmake_policy(SET CMP0053 OLD)" \
        ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt5.wrapQtAppsHook
    util-linuxMinimal
    libunwind
    libselinux
    elfutils
    libsepol
    orc
  ];

  buildInputs = [
    boost
    chromaprint
    fftw
    gettext
    glew
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gstreamer
    gvfs
    libsForQt5.liblastfm
    libpulseaudio
    projectm_3
    protobuf
    libsForQt5.qca-qt5
    libsForQt5.qjson
    qt5.qtbase
    qt5.qtx11extras
    qt5.qttools
    sqlite
    taglib_1
    alsa-lib
  ]
  # gst_plugins needed for setup-hooks
  ++ gst_plugins
  ++ lib.optionals withIpod [
    libgpod
    libplist
    usbmuxd
  ]
  ++ lib.optionals withMTP [ libmtp ]
  ++ lib.optionals withCD [ libcdio ]
  ++ lib.optionals withCloud [ sparsehash ];

  cmakeFlags = [
    (lib.cmakeFeature "FORCE_GIT_REVISION" "1.3.1")
    (lib.cmakeBool "USE_SYSTEM_PROJECTM" true)
    (lib.cmakeBool "SPOTIFY_BLOB" false)
  ];

  preConfigure = ''
    rm -rf ext/{,lib}clementine-spotifyblob
  '';

  postInstall = ''
    wrapQtApp $out/bin/clementine \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0"
  '';

  dontWrapQtApps = true;

  meta = {
    description = "Multiplatform music player";
    homepage = "https://www.clementine-player.org";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "clementine";
  };
})
