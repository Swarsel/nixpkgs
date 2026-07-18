{
  lib,
  stdenv,
  fetchurl,
  dbus,
  dbus-glib,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  evolution-data-server-gtk4,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  libgee,
  meson,
  ninja,
  pkg-config,
  python3,
  readline,
  sqlite,
  telepathy-glib,
  vala,
  telepathySupport ? false,
}:

# TODO: enable more folks backends

stdenv.mkDerivation (finalAttrs: {
  pname = "folks";
  version = "0.15.12";

  src = fetchurl {
    url = "mirror://gnome/sources/folks/${lib.versions.majorMinor finalAttrs.version}/folks-${finalAttrs.version}.tar.xz";
    hash = "sha256-IfROK9q7Huf45Bu5ltEKx9rzXHjEmBd9sMAPWAogqRQ=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # https://gitlab.gnome.org/GNOME/folks/-/merge_requests/81
    ./fix-docs-build-with-eds-3.59.patch
  ];

  postPatch = lib.optionalString telepathySupport ''
    patchShebangs tests/tools/manager-file.py
  '';

  nativeBuildInputs = [
    gettext
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    meson
    ninja
    pkg-config
    vala
  ]
  ++ lib.optionals telepathySupport [
    python3
  ];

  buildInputs = [
    dbus-glib
    evolution-data-server-gtk4 # UI part not needed, using gtk4 version to reduce system closure.
    readline
  ]
  ++ lib.optionals telepathySupport [
    telepathy-glib
  ];

  propagatedBuildInputs = [
    glib
    libgee
    sqlite
  ];

  mesonFlags = [
    "-Ddocs=true"
    "-Dtelepathy_backend=${lib.boolToString telepathySupport}"
    "-Dtests=${lib.boolToString (finalAttrs.finalPackage.doCheck && stdenv.hostPlatform.isLinux)}"
  ];

  # Checks last re-enabled in https://github.com/NixOS/nixpkgs/pull/279843, but timeouts in tests still
  # occur inconsistently
  doCheck = false;

  nativeCheckInputs = [
    dbus
    (python3.withPackages (
      pp: with pp; [
        python-dbusmock
        # The following possibly need to be propagated by dbusmock
        # if they are not optional
        dbus-python
        pygobject3
      ]
    ))
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "folks";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Library that aggregates people from multiple sources to create metacontacts";
    homepage = "https://gitlab.gnome.org/GNOME/folks";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
