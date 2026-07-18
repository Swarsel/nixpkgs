{
  lib,
  stdenv,
  fetchurl,
  docbook_xml_dtd_43,
  docbook_xsl,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  vala,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gcab";
  version = "1.6";

  src = fetchurl {
    url = "mirror://gnome/sources/gcab/${lib.versions.majorMinor finalAttrs.version}/gcab-${finalAttrs.version}.tar.xz";
    hash = "sha256-LwyWFVd8QSaQniUfneBibD7noVI3bBW1VE3xD8h+Vgs=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "devdoc"
    "installedTests"
  ];

  patches = [
    # allow installing installed tests to a separate output
    ./installed-tests-path.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gettext
    gobject-introspection
    gtk-doc
    docbook_xsl
    docbook_xml_dtd_43
  ];

  buildInputs = [
    glib
    zlib
  ];

  # required by libgcab-1.0.pc
  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    "-Dinstalled_tests=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  doCheck = true;

  passthru = {
    tests = {
      installedTests = nixosTests.installed-tests.gcab;
    };

    updateScript = gnome.updateScript {
      packageName = "gcab";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "GObject library to create cabinet files";
    homepage = "https://gitlab.gnome.org/GNOME/gcab";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    mainProgram = "gcab";
    teams = [ lib.teams.gnome ];
  };
})
