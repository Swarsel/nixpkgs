{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  glib,
  glib-networking,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  intltool,
  json-glib,
  libnotify,
  libpeas2,
  libsecret,
  libsoup_3,
  libxml2,
  libxslt,
  pkg-config,
  python3Packages,
  sqlite,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "liferea";
  version = "1.16.12";

  src = fetchurl {
    url = "https://github.com/lwindolf/${pname}/releases/download/v${version}/${pname}-${version}.tar.bz2";
    hash = "sha256-9UDYvUuIhaz31vgq37KFtsfH3B2IzszzMaa/VSN8JW8=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    python3Packages.wrapPython
    intltool
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    libxml2
    libxslt
    sqlite
    libsoup_3
    libpeas2
    gsettings-desktop-schemas
    json-glib
    libsecret
    glib-networking
    libnotify
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ]);

  postFixup = ''
    buildPythonPath ${python3Packages.pycairo}
    patchPythonScript $out/lib/liferea/plugins/trayicon.py

    buildPythonPath ${python3Packages.requests}
    patchPythonScript $out/lib/liferea/plugins/download-manager.py
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://github.com/lwindolf/${pname}";
  };

  meta = {
    description = "GTK-based news feed aggregator";

    longDescription = ''
      Liferea (Linux Feed Reader) is an RSS/RDF feed reader.
      It's intended to be a clone of the Windows-only FeedReader.
      It can be used to maintain a list of subscribed feeds,
      browse through their items, and show their contents.
    '';

    homepage = "http://lzone.de/liferea/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      romildo
      yayayayaka
    ];

    platforms = lib.platforms.linux;
  };
}
