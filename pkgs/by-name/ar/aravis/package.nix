{
  lib,
  stdenv,
  fetchFromGitHub,
  gi-docgen,
  glib,
  gobject-introspection,
  gst_all_1,
  gtk3,
  libusb1,
  libxml2,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  enableFastHeartbeat ? false,
  enableGstPlugin ? true,
  enablePacketSocket ? true,
  enableUsb ? true,
  enableViewer ? true,
}:

assert enableGstPlugin -> gst_all_1 != null;
assert enableViewer -> enableGstPlugin;
assert enableViewer -> gtk3 != null;
assert enableViewer -> wrapGAppsHook3 != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "aravis";
  version = "0.8.35";

  src = fetchFromGitHub {
    owner = "AravisProject";
    repo = "aravis";
    tag = finalAttrs.version;
    hash = "sha256-RRIYZHtljZ44s1kmmUI1KMx92+PLLI/eCJRs4m0+egg=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "lib"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gi-docgen
    gobject-introspection
  ]
  ++ lib.optional enableViewer wrapGAppsHook3;

  buildInputs = [
    glib
    libxml2
  ]
  ++ lib.optional enableUsb libusb1
  ++ lib.optionals (enableViewer || enableGstPlugin) (
    with gst_all_1;
    [
      gstreamer
      gst-plugins-base
      (gst-plugins-good.override { gtkSupport = true; })
      gst-plugins-bad
    ]
  )
  ++ lib.optionals enableViewer [ gtk3 ];

  mesonFlags = [
  ]
  ++ lib.optional enableFastHeartbeat "-Dfast-heartbeat=enabled"
  ++ lib.optional (!enableGstPlugin) "-Dgst-plugin=disabled"
  ++ lib.optional (!enableViewer) "-Dviewer=disabled"
  ++ lib.optional (!enableUsb) "-Dviewer=disabled"
  ++ lib.optional (!enablePacketSocket) "-Dpacket-socket=disabled";

  doCheck = true;
  # needed for fakegv tests
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Library for video acquisition using GenICam cameras";

    longDescription = ''
      Implements the gigabit ethernet and USB3 protocols used by industrial cameras.
    '';

    # the documentation is the best working homepage that's not the Github repo
    homepage = "https://aravisproject.github.io/docs/aravis-0.8";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ tpw_rules ];
    platforms = lib.platforms.unix;
  };
})
