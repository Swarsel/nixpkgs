{
  lib,
  stdenv,
  fetchurl,
  apple-sdk_gstreamer,
  bash-completion,
  directoryListingUpdater,
  flex,
  gettext,
  gobject-introspection,
  gst-devtools,
  gst-plugins-bad,
  gst-plugins-base,
  hotdoc,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-editing-services";
  version = "1.28.4";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-editing-services/gst-editing-services-${finalAttrs.version}.tar.xz";
    hash = "sha256-b361Xlhxjd5bWGn2Ge2Q6/Owz6A3bBacG4P8dzgRkUo=";
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
    pkg-config
    gettext
    gobject-introspection
    python3
    flex
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ];

  buildInputs = [
    bash-completion
    libxml2
    gst-devtools
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  propagatedBuildInputs = [
    gst-plugins-base
    gst-plugins-bad
  ];

  mesonFlags = [
    (lib.mesonEnable "doc" enableDocumentation)
    (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck)
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
    description = "Library for creation of audio/video non-linear editors";
    homepage = "https://gstreamer.freedesktop.org";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.unix;
    mainProgram = "ges-launch-1.0";
  };
})
