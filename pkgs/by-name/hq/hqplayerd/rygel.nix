{
  lib,
  stdenv,
  fetchurl,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gst_all_1,
  # libsoup_2_4,
  gtk3,
  # gssdp,
  # gupnp,
  gupnp-av,
  gupnp-dlna,
  libgee,
  libmediaart,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  sqlite,
  systemd,
  tinysparql,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "rygel";
  version = "0.40.4";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "c22K2+hhX2y8j8//mEXcmF/RDhZinaI2tLUtvt8KNIs=";
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
    meson
    ninja
    pkg-config
    vala
    gettext
    libxml2
    gobject-introspection
    wrapGAppsHook3
    python3
  ];

  buildInputs = [
    glib
    # gssdp
    # gupnp
    gupnp-av
    gupnp-dlna
    libgee
    # libsoup_2_4
    gtk3
    libmediaart
    sqlite
    systemd
    tinysparql
    shared-mime-info
  ]
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
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gnome.${pname}";
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Home media solution (UPnP AV MediaServer) that allows you to easily share audio, video and pictures to other devices";
    homepage = "https://gitlab.gnome.org/GNOME/rygel";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    # libsoup 2.4 and its dependents (specifically gupnp and gssdp) were
    # removed due to being insecure and having many known vulnerabilities. this
    # thus no longer builds. this derivation might be obsoleted by updating to
    # hqplayer 6.0, as it ostensibly removes the need for rygel.
    broken = true;
    teams = [ lib.teams.gnome ];
  };
}
