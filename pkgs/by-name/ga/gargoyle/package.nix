{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchDebianPatch,
  fluidsynth,
  fmt,
  freetype,
  libjpeg,
  libopenmpt,
  libpng,
  libsndfile,
  libvorbis,
  mpg123,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gargoyle";
  version = "2026.1.1";

  src = fetchFromGitHub {
    owner = "garglk";
    repo = "garglk";
    tag = finalAttrs.version;
    hash = "sha256-cBFsxbXQa2xqCwW6Gd90vupAykkHvRjeM5yjA383doQ=";
  };

  patches = [
    (fetchDebianPatch {
      pname = "gargoyle-free";
      version = "2023.1+dfsg";
      debianRevision = "4";
      hash = "sha256-eMx/RlUpq5Ez+1L8VZo40Y3h2ZKkqiQEmKTlkZRMXnI=";
      patch = "ftbfs_gcc14.patch";
    })
  ];

  postPatch = ''
    substituteInPlace garglk/garglk.pc.in \
      --replace-fail "\''${prefix}/@CMAKE_INSTALL_LIBDIR@" "@CMAKE_INSTALL_FULL_LIBDIR@" \
      --replace-fail "\''${prefix}/@CMAKE_INSTALL_INCLUDEDIR@" "@CMAKE_INSTALL_FULL_INCLUDEDIR@"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    fluidsynth
    fmt
    freetype
    libjpeg
    libopenmpt
    libpng
    libsndfile
    libvorbis
    mpg123
    qt6.qtbase
    qt6.qtmultimedia
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    qt6.qtwayland
  ];

  cmakeFlags = [
    (lib.cmakeFeature "INTERFACE" "QT")
    (lib.cmakeFeature "SOUND" "QT")
    (lib.cmakeBool "WITH_QT6" true)
    # fatal error: 'macglk_startup.h' file not found
    (lib.cmakeBool "WITH_AGILITY" (!stdenv.hostPlatform.isDarwin))
    (lib.cmakeBool "WITH_LEVEL9" (!stdenv.hostPlatform.isDarwin))
    (lib.cmakeBool "WITH_MAGNETIC" (!stdenv.hostPlatform.isDarwin))
  ];

  meta = {
    description = "Interactive fiction interpreter GUI";
    homepage = "http://ccxvii.net/gargoyle/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gargoyle";
  };
})
