{
  lib,
  stdenv,
  fetchurl,
  _experimental-update-script-combinators,
  apple-sdk_gstreamer,
  cairo,
  cargo,
  common-updater-scripts,
  directoryListingUpdater,
  fetchpatch,
  gobject-introspection,
  gst-plugins-bad,
  gst-plugins-base,
  gst-rtsp-server,
  gstreamer,
  hotdoc,
  json-glib,
  meson,
  ninja,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-devtools";
  version = "1.28.4";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-devtools/gst-devtools-${finalAttrs.version}.tar.xz";
    hash = "sha256-EdTxGIY506l2IDkGW7t7LDCbeo7Mb6Su0SJFVovwDbM=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    rustPlatform.cargoSetupHook
    rustc
    cargo
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ];

  buildInputs = [
    cairo
    python3
    json-glib
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    apple-sdk_gstreamer
  ];

  propagatedBuildInputs = [
    gstreamer
    gst-plugins-base
    gst-plugins-bad
    gst-rtsp-server
  ];

  mesonFlags = [
    (lib.mesonEnable "doc" enableDocumentation)
  ];

  preFixup = ''
    moveToOutput "lib/gstreamer-1.0/pkgconfig" "$dev"
  '';

  __structuredAttrs = true;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      src
      cargoRoot
      ;

    hash = "sha256-5VYzDwAMyVN2HR/sS8rCwTR7UW/tt60AS7wZMjx+w74=";
    name = "gst-devtools-${finalAttrs.version}";
  };

  cargoRoot = "dots-viewer";

  depsBuildBuild = [
    pkg-config
  ];

  separateDebugInfo = true;

  passthru = {
    updateScript =
      let
        updateSource = directoryListingUpdater { odd-unstable = true; };

        updateLockfile = {
          command = [
            "sh"
            "-c"
            ''
              PATH=${
                lib.makeBinPath [
                  common-updater-scripts
                ]
              }
              update-source-version gst_all_1.gst-devtools --ignore-same-version --source-key=cargoDeps.vendorStaging > /dev/null
            ''
          ];

          # Experimental feature: do not copy!
          supportedFeatures = [ "silent" ];
        };
      in
      _experimental-update-script-combinators.sequence [
        updateSource
        updateLockfile
      ];
  };

  meta = {
    description = "Integration testing infrastructure for the GStreamer framework";
    homepage = "https://gstreamer.freedesktop.org";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.unix;
  };
})
