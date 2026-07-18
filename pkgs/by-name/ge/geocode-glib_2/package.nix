{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  json-glib,
  libsoup_3,
  meson,
  mesonEmulatorHook,
  ninja,
  nixosTests,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geocode-glib";
  version = "3.26.4";

  src = fetchurl {
    url = "mirror://gnome/sources/geocode-glib/${lib.versions.majorMinor finalAttrs.version}/geocode-glib-${finalAttrs.version}.tar.xz";
    sha256 = "LZpoJtFYRwRJoXOHEiFZbaD4Pr3P+YuQxwSQiQVqN6o=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
    "installedTests"
  ];

  patches = [
    ./installed-tests-path.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gettext
    gtk-doc
    docbook-xsl-nons
    gobject-introspection
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    libsoup_3
    json-glib
  ];

  mesonFlags = [
    "-Dsoup2=false"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  passthru = {
    tests = {
      installed-tests = nixosTests.installed-tests.geocode-glib;
    };

    updateScript = gnome.updateScript {
      attrPath = "geocode-glib_2";
      packageName = "geocode-glib";
    };
  };

  meta = {
    description = "Convenience library for the geocoding and reverse geocoding using Nominatim service";
    homepage = "https://gitlab.gnome.org/GNOME/geocode-glib";
    changelog = "https://gitlab.gnome.org/GNOME/geocode-glib/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
