{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-utils,
  at-spi2-core,
  cmake,
  curl,
  darwin,
  dbus,
  elfutils,
  flac,
  gitMinimal,
  glew,
  gtest,
  jasper,
  lame,
  libGLU,
  libarchive,
  libdatrie,
  libepoxy,
  libexif,
  libmpg123,
  libogg,
  libopus,
  libselinux,
  libsepol,
  libsndfile,
  libthai,
  libunarr,
  libusb1,
  libvorbis,
  libxdmcp,
  libxkbcommon,
  libxtst,
  lsb-release,
  lz4,
  makeWrapper,
  pkg-config,
  portaudio,
  rapidjson,
  shapelib,
  sqlite,
  tinyxml,
  util-linux,
  wrapGAppsHook3,
  wxwidgets_3_2,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opencpn";
  version = "5.14.0";

  src = fetchFromGitHub {
    owner = "OpenCPN";
    repo = "OpenCPN";
    rev = "Release_${finalAttrs.version}";
    hash = "sha256-2yCVv1wRkmRJ2FBwg1CJ9xkXUPx0TPSkRHiNZXaMJZQ=";
  };

  patches = [
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -i '/fixup_bundle/d; /NO_DEFAULT_PATH/d' CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    gtest
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    lsb-release
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.DarwinTools
    makeWrapper
  ];

  buildInputs = [
    at-spi2-core
    curl
    dbus
    flac
    gitMinimal
    shapelib
  ]
  ++ [
    glew
    jasper
    libGLU
    libarchive
    libdatrie
    libepoxy
    libexif
    libogg
    libopus
    libsndfile
    libthai
    libunarr
    libusb1
    libvorbis
    libxkbcommon
    lz4
    libmpg123
    portaudio
    rapidjson
    sqlite
    tinyxml
    wxwidgets_3_2
    xz
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-utils
    libselinux
    libsepol
    util-linux
    libxdmcp
    libxtst
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform elfutils) [
    elfutils
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    lame
  ];

  cmakeFlags = [
    "-DOCPN_BUNDLE_DOCS=true"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # Override OpenCPN platform detection.
    "-DOCPN_TARGET_TUPLE=unknown;unknown;${stdenv.hostPlatform.linuxArch}"
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals (!stdenv.hostPlatform.isx86) [
      "-DSQUISH_USE_SSE=0"
    ]
  );

  doCheck = true;

  postInstall = lib.optionals stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv $out/bin/OpenCPN.app $out/Applications
    makeWrapper $out/Applications/OpenCPN.app/Contents/MacOS/OpenCPN $out/bin/opencpn
  '';

  meta = {
    description = "Concise ChartPlotter/Navigator";
    homepage = "https://opencpn.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      kragniz
      lovesegfault
    ];

    platforms = lib.platforms.unix;
  };
})
