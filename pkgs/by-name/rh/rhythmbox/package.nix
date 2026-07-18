{
  lib,
  stdenv,
  fetchurl,
  brasero-unwrapped, # libdvdcss is not needed for rhythmbox
  check,
  desktop-file-utils,
  glib,
  gnome,
  gobject-introspection,
  grilo,
  gst_all_1,
  gtk3,
  itstool,
  json-glib,
  libdmapsharing,
  libgpod,
  libgudev,
  libmtp,
  libnotify,
  libpeas,
  libsecret,
  libsoup_3,
  libxml2,
  lirc,
  meson,
  ninja,
  pkg-config,
  python3,
  tdb,
  totem-pl-parser,
  vala,
  wrapGAppsHook3,
  gst_plugins ? with gst_all_1; [
    gst-plugins-good
    gst-plugins-ugly
  ],
}:

stdenv.mkDerivation rec {
  pname = "rhythmbox";
  version = "3.4.9";

  src = fetchurl {
    url = "mirror://gnome/sources/rhythmbox/${lib.versions.majorMinor version}/rhythmbox-${version}.tar.xz";
    sha256 = "5CKRoY33oh/+azUr9z8F1+KYu04FvOWWf5jujO5ECPE=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    vala
    glib
    itstool
    wrapGAppsHook3
    desktop-file-utils
    gobject-introspection
  ];

  buildInputs = [
    python3
    libsoup_3
    libxml2
    tdb
    json-glib

    glib
    gtk3
    libpeas
    totem-pl-parser
    libgudev
    libgpod
    libmtp
    lirc
    brasero-unwrapped
    grilo

    python3.pkgs.pygobject3

    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    libdmapsharing # for daap support
    libsecret
    libnotify
  ]
  ++ gst_plugins;

  mesonFlags = [
    "-Ddaap=enabled"
    "-Dtests=disabled"
  ];

  # Requires DISPLAY
  doCheck = false;

  nativeCheckInputs = [
    check
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "$out/lib/rhythmbox/plugins/"
    )
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Music playing application for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/rhythmbox";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
