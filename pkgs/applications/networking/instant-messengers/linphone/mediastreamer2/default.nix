{
  lib,
  bctoolbox,
  bzrtp,
  ffmpeg_4,
  glew,
  gsm,
  libopus,
  libpulseaudio,
  libsm,
  libv4l,
  libvpx,
  libx11,
  libxext,
  mkLinphoneDerivation,
  ortp,
  python3,
  qt6Packages,
  speex,
  sqlite,
  srtp,
}:
mkLinphoneDerivation (finalAttrs: {
  pname = "mediastreamer2";

  patches = [
    # Plugins directory is normally fixed during compile time. This patch makes
    # it possible to set the plugins directory run time with an environment
    # variable MEDIASTREAMER_PLUGINS_DIR. This makes it possible to construct a
    # plugin directory with desired plugins and wrap executables so that the
    # environment variable points to that directory.
    ./plugins_dir.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    python3
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
  ];

  propagatedBuildInputs = [
    # Made by BC
    bctoolbox
    bzrtp
    ortp

    ffmpeg_4
    glew
    libsm
    libx11
    libxext
    libpulseaudio
    libv4l
    speex
    srtp
    sqlite

    # Optional
    gsm # GSM audio codec
    libopus # Opus audio codec
    libvpx # VP8 video codec
  ];

  cmakeFlags = [
    "-DENABLE_QT_GL=ON" # Build necessary MSQOGL plugin for Linphone desktop
    "-DCMAKE_C_FLAGS=-DGIT_VERSION=\"v${finalAttrs.version}\""
    "-DENABLE_STRICT=NO" # Disable -Werror
    "-DENABLE_UNIT_TESTS=NO" # Do not build test executables
  ];

  env.NIX_LDFLAGS = "-lXext";
  dontWrapQtApps = true;

  meta = {
    description = "Powerful and lightweight streaming engine specialized for voice/video telephony applications. Part of the Linphone project";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
  };
})
