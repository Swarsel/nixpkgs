{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ffmpeg,
  filter-audio,
  kdePackages,
  libexif,
  libopus,
  libpthread-stubs,
  libsodium,
  libtoxcore,
  libvpx,
  libxdmcp,
  libxscrnsaver,
  openal,
  perl,
  pkg-config,
  qrencode,
  qt6,
  sqlcipher,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtox";
  version = "1.18.3";

  src = fetchFromGitHub {
    owner = "TokTok";
    repo = "qTox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5pH39NsJdt4+ldlbpkvA0n/X/LkEUEv4UL1K/W3BqmM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ perl ];

  buildInputs = [
    kdePackages.sonnet
    libtoxcore
    libpthread-stubs
    libxdmcp
    libxscrnsaver
    ffmpeg
    filter-audio
    libexif
    libopus
    libsodium
    libvpx
    openal
    qrencode
    qt6.qtbase
    qt6.qtsvg
    sqlcipher
  ];

  cmakeFlags = [
    "-DGIT_DESCRIBE=v${finalAttrs.version}"
    "-DTIMESTAMP=1"
  ];

  meta = {
    description = "Qt Tox client";
    homepage = "https://tox.chat";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      akaWolf
      peterhoeg
    ];

    platforms = lib.platforms.all;
    mainProgram = "qtox";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
