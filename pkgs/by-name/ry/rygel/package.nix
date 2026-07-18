{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  gdk-pixbuf,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gssdp_1_6,
  gst_all_1,
  gtk4,
  gupnp-av,
  gupnp-dlna,
  gupnp_1_6,
  libgee,
  libmediaart,
  libsoup_3,
  libx11,
  libxml2,
  libxslt,
  meson,
  ninja,
  pipewire,
  pkg-config,
  python3,
  rygel,
  shared-mime-info,
  sqlite,
  systemd,
  tinysparql,
  vala,
  wrapGAppsHook4,
  wrapGAppsNoGuiHook,
  withGtk ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rygel";
  version = "45.2";

  src = fetchurl {
    url = "mirror://gnome/sources/rygel/${lib.versions.major finalAttrs.version}/rygel-${finalAttrs.version}.tar.xz";
    hash = "sha256-IOV7cLFahl133Dj594arxSxksRH+X5OKYsKNcS3xMx0=";
  };

  # TODO: split out lib
  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./add-option-for-installation-sysconfdir.patch
  ];

  postPatch = ''
    patchShebangs data/xml/process-xml.py
  '';

  nativeBuildInputs = [
    docbook-xsl-nons
    meson
    ninja
    pkg-config
    vala
    gettext
    libxml2
    libxslt # for xsltproc
    gobject-introspection
    (if withGtk then wrapGAppsHook4 else wrapGAppsNoGuiHook)
    python3
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gssdp_1_6
    gupnp_1_6
    gupnp-av
    gupnp-dlna
    libgee
    libsoup_3
    libmediaart
    pipewire
    # Move this to withGtk when it's not unconditionally included
    # https://gitlab.gnome.org/GNOME/rygel/-/issues/221
    # https://gitlab.gnome.org/GNOME/rygel/-/merge_requests/27
    libx11
    sqlite
    systemd
    tinysparql
    shared-mime-info
  ]
  ++ lib.optionals withGtk [ gtk4 ]
  ++ (with gst_all_1; [
    gstreamer
    gst-editing-services
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ]);

  mesonFlags = [
    "-Dsystemd-user-units-dir=${placeholder "out"}/lib/systemd/user"
    "-Dapi-docs=false"
    "--sysconfdir=/etc"
    "-Dsysconfdir_install=${placeholder "out"}/etc"
    (lib.mesonEnable "gtk" withGtk)
  ];

  doCheck = true;

  passthru = {
    noGtk = rygel.override { withGtk = false; };

    updateScript = gnome.updateScript {
      packageName = "rygel";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Home media solution (UPnP AV MediaServer) that allows you to easily share audio, video and pictures to other devices";
    homepage = "https://gitlab.gnome.org/GNOME/rygel";
    changelog = "https://gitlab.gnome.org/GNOME/rygel/-/blob/rygel-${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
