{
  lib,
  stdenv,
  fetchurl,
  a52dec,
  apple-sdk_gstreamer,
  directoryListingUpdater,
  gettext,
  gst-plugins-base,
  gst-plugins-ugly,
  hotdoc,
  libcdio,
  libdvdread,
  libintl,
  libmad,
  libmpeg2,
  meson,
  ninja,
  orc,
  pkg-config,
  python3,
  x264,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
  enableGplPlugins ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-plugins-ugly";
  version = "1.28.4";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-${finalAttrs.version}.tar.xz";
    hash = "sha256-VIbNFFxa9DJZ/TfKylnQSOKmfdsHCC6o9Q7w8CqF+KU=";
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
    gst-plugins-base
    orc
    libintl
  ]
  ++ lib.optionals enableGplPlugins [
    a52dec
    libcdio
    libdvdread
    libmad
    libmpeg2
    x264
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  mesonFlags = [
    "-Dglib_debug=disabled" # cast checks should be disabled on stable releases
    "-Dsidplay=disabled" # sidplay / sidplay/player.h isn't packaged in nixpkgs as of writing
    (lib.mesonEnable "doc" enableDocumentation)
  ]
  ++ (
    if enableGplPlugins then
      [
        "-Dgpl=enabled"
      ]
    else
      [
        "-Da52dec=disabled"
        "-Dcdio=disabled"
        "-Ddvdread=disabled"
        "-Dmpeg2dec=disabled"
        "-Dsidplay=disabled"
        "-Dx264=disabled"
      ]
  );

  preFixup = ''
    moveToOutput "lib/gstreamer-1.0/pkgconfig" "$dev"
  '';

  __structuredAttrs = true;
  separateDebugInfo = true;

  passthru = {
    tests = {
      lgplOnly = gst-plugins-ugly.override {
        enableGplPlugins = false;
      };
    };

    updateScript = directoryListingUpdater { odd-unstable = true; };
  };

  meta = {
    description = "Gstreamer Ugly Plugins";

    longDescription = ''
      a set of plug-ins that have good quality and correct functionality,
      but distributing them might pose problems.  The license on either
      the plug-ins or the supporting libraries might not be how we'd
      like. The code might be widely known to present patent problems.
    '';

    homepage = "https://gstreamer.freedesktop.org";
    license = if enableGplPlugins then lib.licenses.gpl2Plus else lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.unix;
  };
})
