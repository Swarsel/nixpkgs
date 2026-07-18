{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  glib,
  jansson,
  janus-gateway,
  libbsd,
  libdrm,
  libevent,
  libjpeg,
  libopus,
  nixosTests,
  pkg-config,
  python3Packages,
  speex,
  systemdLibs,
  which,
  withJanus ? true,
  withPython ? true,
  withSystemd ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ustreamer";
  version = "6.56";

  src = fetchFromGitHub {
    owner = "pikvm";
    repo = "ustreamer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-02mEZ14fwCrdmXUGhyKrkoo5IZ6/pDJZ/oREaZZe1RA=";
  };

  nativeBuildInputs = [
    pkg-config
    which
  ];

  buildInputs = [
    libbsd
    libevent
    libjpeg
    libdrm
  ]
  ++ lib.optionals withPython (
    with python3Packages;
    [
      python
      setuptools
      build
      pip
    ]
  )
  ++ lib.optionals withSystemd [
    systemdLibs
  ]
  ++ lib.optionals withJanus [
    janus-gateway
    glib
    alsa-lib
    jansson
    speex
    libopus
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "WITH_V4P=1"
  ]
  ++ lib.optionals withPython [
    "WITH_PYTHON=1"
  ]
  ++ lib.optionals withSystemd [
    "WITH_SYSTEMD=1"
  ]
  ++ lib.optionals withJanus [
    "WITH_JANUS=1"
    # Workaround issues with Janus C Headers
    # https://github.com/pikvm/ustreamer/blob/793f24c4/docs/h264.md#fixing-janus-c-headers
    "CFLAGS=-I${lib.getDev janus-gateway}/include/janus"
  ];

  enableParallelBuilding = true;
  passthru.tests = { inherit (nixosTests) ustreamer; };

  meta = {
    description = "Lightweight and fast MJPG-HTTP streamer";

    longDescription = ''
      µStreamer is a lightweight and very quick server to stream MJPG video from
      any V4L2 device to the net. All new browsers have native support of this
      video format, as well as most video players such as mplayer, VLC etc.
      µStreamer is a part of the Pi-KVM project designed to stream VGA and HDMI
      screencast hardware data with the highest resolution and FPS possible.
    '';

    homepage = "https://github.com/pikvm/ustreamer";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      tfc
      matthewcroughan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ustreamer";
  };
})
