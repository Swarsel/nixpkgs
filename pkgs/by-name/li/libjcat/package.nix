{
  lib,
  stdenv,
  fetchFromGitHub,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  glib,
  gnutls,
  gobject-introspection,
  gpgme,
  gtk-doc,
  json-glib,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  python3,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libjcat";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "libjcat";
    rev = finalAttrs.version;
    sha256 = "sha256-PLaxeRWbPWXbS9QvMzYS4FTBNw9BDpMf1z2gYNZQa2c=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "devdoc"
    "man"
    "installedTests"
  ];

  patches = [
    # Installed tests are installed to different output
    ./installed-tests-path.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    docbook_xml_dtd_43
    docbook-xsl-nons
    gobject-introspection
    vala
    gnutls
    gtk-doc
    python3
  ];

  buildInputs = [
    glib
    json-glib
    gnutls
    gpgme
  ];

  mesonFlags = [
    "-Dgtkdoc=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  doCheck = true;

  passthru = {
    tests = {
      installed-tests = nixosTests.installed-tests.libjcat;
    };
  };

  meta = {
    description = "Library for reading and writing Jcat files";
    homepage = "https://github.com/hughsie/libjcat";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "jcat-tool";
  };
})
