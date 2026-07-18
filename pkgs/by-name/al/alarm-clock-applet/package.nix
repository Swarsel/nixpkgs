{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gst_all_1,
  libayatana-appindicator,
  libnotify,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alarm-clock-applet";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "alarm-clock-applet";
    repo = "alarm-clock";
    tag = finalAttrs.version;
    hash = "sha256-10hkWWEsAUJnGeu35bR5d0RFKd9CKDZI7WGMzmEM3rI=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-NP1PlEw5AFWZgywvppIs2e+5EfMSPbU4Pq2tIfwODrQ=";
      url = "https://github.com/alarm-clock-applet/alarm-clock/commit/6a11003099660dfae0e3d5800f49880d3a26f5ec.patch";
    })
    (fetchpatch {
      hash = "sha256-xKaaNfXsv9Ckwy73r1n93kOWIZ01fU5GDqYSQCch1Kc=";
      url = "https://github.com/alarm-clock-applet/alarm-clock/commit/cbcf22fac5b45ab251ade2e7e993f422f33f926e.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    libnotify
    libayatana-appindicator
  ];

  cmakeFlags = [
    # gconf is already deprecated
    "-DENABLE_GCONF_MIGRATION=OFF"
  ];

  meta = {
    description = "Fully-featured alarm clock with an indicator";
    homepage = "https://alarm-clock-applet.github.io";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "alarm-clock-applet";
  };
})
