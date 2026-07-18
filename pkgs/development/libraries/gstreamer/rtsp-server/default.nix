{
  lib,
  stdenv,
  fetchurl,
  apple-sdk_gstreamer,
  directoryListingUpdater,
  gettext,
  gobject-introspection,
  gst-plugins-bad,
  gst-plugins-base,
  hotdoc,
  meson,
  ninja,
  pkg-config,
  python3,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-rtsp-server";
  version = "1.28.4";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-rtsp-server/gst-rtsp-server-${finalAttrs.version}.tar.xz";
    hash = "sha256-v7Z4BUK/DUAnNiMq6ubFoblDxEV3W/QDBby4bKcHBaA=";
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
    gobject-introspection
    pkg-config
    python3
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ];

  buildInputs = [
    gst-plugins-base
    gst-plugins-bad
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  mesonFlags = [
    "-Dglib_debug=disabled" # cast checks should be disabled on stable releases
    "-Dexamples=disabled" # requires many dependencies and probably not useful for our users
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
    description = "GStreamer RTSP server";

    longDescription = ''
      A library on top of GStreamer for building an RTSP server.
    '';

    homepage = "https://gstreamer.freedesktop.org";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ bkchr ];
    platforms = lib.platforms.unix;
  };
})
