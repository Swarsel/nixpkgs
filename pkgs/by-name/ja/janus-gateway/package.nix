{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boringssl,
  curl,
  ffmpeg,
  gengetopt,
  glib,
  jansson,
  libconfig,
  libmicrohttpd,
  libnice,
  libogg,
  libopus,
  libuv,
  libwebsockets,
  pkg-config,
  sofia_sip,
  srtp,
  usrsctp,
  zlib,
}:

let
  libwebsockets_janus = libwebsockets.overrideAttrs (_: {
    configureFlags = [
      "-DLWS_MAX_SMP=1"
      "-DLWS_WITHOUT_EXTENSIONS=0"
    ];
  });
in

stdenv.mkDerivation (finalAttrs: {
  pname = "janus-gateway";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "meetecho";
    repo = "janus-gateway";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/201zFwahtN9cH+iHqeAi5FCTXUE3Z6J1G5Xh0xzc3Q=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gengetopt
  ];

  buildInputs = [
    glib
    libconfig
    libnice
    jansson
    boringssl
    zlib
    srtp
    libuv
    libmicrohttpd
    curl
    libwebsockets_janus
    sofia_sip
    libogg
    libopus
    usrsctp
    ffmpeg
  ];

  configureFlags = [
    "--enable-boringssl=${lib.getDev boringssl}"
    "--enable-libsrtp2"
    "--enable-turn-rest-api"
    "--enable-json-logger"
    "--enable-gelf-event-handler"
    "--enable-post-processing"
  ];

  makeFlags = [
    "BORINGSSL_LIBS=-L${lib.getLib boringssl}/lib"
    # Linking with CXX because boringssl static libraries depend on C++ stdlib.
    # Upstream issue: https://www.github.com/meetecho/janus-gateway/issues/3456
    "CCLD=${stdenv.cc.targetPrefix}c++"
  ];

  postInstall = ''
    moveToOutput share/janus "$doc"
    moveToOutput etc "$doc"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "General purpose WebRTC server";
    homepage = "https://janus.conf.meetecho.com/";
    changelog = "https://github.com/meetecho/janus-gateway/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
  };
})
