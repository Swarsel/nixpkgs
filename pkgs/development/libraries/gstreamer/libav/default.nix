{
  lib,
  stdenv,
  fetchurl,
  apple-sdk_gstreamer,
  directoryListingUpdater,
  ffmpeg-headless,
  gettext,
  gst-plugins-base,
  gstreamer,
  hotdoc,
  meson,
  ninja,
  pkg-config,
  python3,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-libav";
  version = "1.28.4";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-${finalAttrs.version}.tar.xz";
    hash = "sha256-vRel3yh0p6WLy697lAIjN5rZYTYk246teD2wPnS7kEs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs \
      scripts/extract-release-date-from-doap-file.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    python3
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ];

  buildInputs = [
    gstreamer
    gst-plugins-base
    ffmpeg-headless
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  mesonFlags = [
    (lib.mesonEnable "doc" enableDocumentation)
  ];

  preFixup = ''
    moveToOutput "lib/gstreamer-1.0/pkgconfig" "$dev"
  '';

  __structuredAttrs = true;
  separateDebugInfo = true;

  passthru = {
    updateScript = directoryListingUpdater { odd-unstable = true; };
  };

  meta = {
    description = "FFmpeg plugin for GStreamer";
    homepage = "https://gstreamer.freedesktop.org";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.unix;
  };
})
