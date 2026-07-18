{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_gstreamer,
  autoreconfHook,
  gst_all_1,
  ipu6-camera-hal,
  libdrm,
  libva,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "icamerasrc-${ipu6-camera-hal.ipuVersion}";
  version = "unstable-2025-12-26";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "icamerasrc";
    tag = "20251226_1140_191_PTL_PV_IoT";
    hash = "sha256-BYURJfNz4D8bXbSeuWyUYnoifozFOq6rSfG9GBKVoHo=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    ipu6-camera-hal
    libdrm
    libva
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error"
    # gstcameradeinterlace.cpp:55:10: fatal error: gst/video/video.h: No such file or directory
    "-I${gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
  ];

  preConfigure = ''
    # https://github.com/intel/ipu6-camera-hal/issues/1
    export CHROME_SLIM_CAMHAL=ON
    # https://github.com/intel/icamerasrc/issues/22
    export STRIP_VIRTUAL_CHANNEL_CAMHAL=ON
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;
  separateDebugInfo = true;

  passthru = {
    inherit (ipu6-camera-hal) ipuVersion;
  };

  meta = {
    description = "GStreamer Plugin for MIPI camera support through the IPU6/IPU6EP/IPU6SE on Intel Tigerlake/Alderlake/Jasperlake platforms";
    homepage = "https://github.com/intel/icamerasrc/tree/icamerasrc_slim_api";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
