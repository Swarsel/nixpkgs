{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  desktop-file-utils,
  glib-networking,
  gobject-introspection,
  graphviz,
  gst_all_1,
  gtk4,
  libGL,
  libadwaita,
  libmicrodns,
  libpeas2,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  shared-mime-info,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clapper-unwrapped";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "Rafostar";
    repo = "clapper";
    tag = finalAttrs.version;
    hash = "sha256-WU004/ea3H0eBYd6XPDsEQaoAuShvZzOu3QOweFvdIo=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  postPatch = ''
    patchShebangs --build build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    cmake
    ninja
    pkg-config
    desktop-file-utils # for update-desktop-database
    gtk4 # for gtk4-update-icon-cache
    shared-mime-info # for update-mime-database
    vala
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    glib-networking # for TLS support
    gtk4
    libGL
    libadwaita
    libsoup_3
    libmicrodns
    libpeas2
    graphviz # for feature "pipeline-preview"
  ];

  preFixup = ''
    mkdir -p $out/share/gsettings-schemas
    # alias clapper-unwrapped schemas to also provide clapper schemas.
    # the precise schema patch can vary based on host platform.
    schemas=$(basename $lib/share/gsettings-schemas/clapper-unwrapped-*)
    cp -r $lib/share/gsettings-schemas/$schemas $out/share/gsettings-schemas/''${schemas/clapper-unwrapped-/clapper-}
  '';

  meta = {
    description = "GNOME media player built using GTK4 toolkit and powered by GStreamer with OpenGL rendering";

    longDescription = ''
      Clapper is a GNOME media player built using the GTK4 toolkit.
      The media player is using GStreamer as a media backend.
    '';

    homepage = "https://github.com/Rafostar/clapper";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
  };
})
