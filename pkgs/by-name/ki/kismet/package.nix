{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  binutils,
  elfutils,
  glib,
  libbtbb,
  libcap,
  libmicrohttpd,
  libnl,
  libpcap,
  libusb1,
  libwebsockets,
  lm_sensors,
  mosquitto,
  networkmanager,
  nix-update-script,
  nixosTests,
  openssl,
  pcre2,
  pkg-config,
  protobuf,
  protobufc,
  python3,
  rtl-sdr-librtlsdr,
  sqlite,
  zlib,
  withNetworkManager ? false,
  withPython ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  withSensors ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kismet";
  version = "2025-09-R1";

  src = fetchFromGitHub {
    owner = "kismetwireless";
    repo = "kismet";
    tag = "kismet-${finalAttrs.version}";
    hash = "sha256-bwgeBIa5P1he0azWBu1YTXS9EGlHdJK8hS6A5Rj9XU4=";
  };

  postPatch = ''
    substituteInPlace Makefile.in \
      --replace-fail "-m 4550" ""
    substituteInPlace configure.ac \
      --replace-fail "pkg-config" "$PKG_CONFIG"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    protobuf
    protobufc
  ]
  ++ lib.optionals withPython [
    (python3.withPackages (ps: [
      ps.numpy
      ps.protobuf
      ps.pyserial
      ps.setuptools
      ps.websockets
    ]))
  ];

  buildInputs = [
    binutils
    elfutils
    libbtbb
    libcap
    libmicrohttpd
    libnl
    libpcap
    openssl
    libusb1
    libwebsockets
    mosquitto
    pcre2
    protobuf
    protobufc
    rtl-sdr-librtlsdr
    sqlite
    zlib
  ]
  ++ lib.optionals withNetworkManager [
    networkmanager
    glib
  ]
  ++ lib.optionals withSensors [
    lm_sensors
  ];

  configureFlags = [
    "--disable-wifi-coconut" # Until https://github.com/kismetwireless/kismet/issues/478
  ]
  ++ lib.optionals (!withNetworkManager) [
    "--disable-libnm"
  ]
  ++ lib.optionals (!withPython) [
    "--disable-python-tools"
  ]
  ++ lib.optionals (!withSensors) [
    "--disable-lmsensors"
  ];

  postConfigure = ''
    sed -e 's/-o $(INSTUSR)//' \
        -e 's/-g $(INSTGRP)//' \
        -e 's/-g $(MANGRP)//' \
        -e 's/-g $(SUIDGROUP)//' \
        -i Makefile
  '';

  enableParallelBuilding = true;

  passthru = {
    tests.kismet = nixosTests.kismet;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^kismet-(\\d+-\\d+-.+)$"
      ];
    };
  };

  meta = {
    description = "Wireless network sniffer";
    homepage = "https://www.kismetwireless.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ numinit ];
    platforms = lib.platforms.linux;
  };
})
