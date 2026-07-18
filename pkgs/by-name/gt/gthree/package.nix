{
  lib,
  stdenv,
  fetchFromGitHub,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  fetchpatch,
  glib,
  gobject-introspection,
  graphene,
  gtk-doc,
  gtk3,
  json-glib,
  libepoxy,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gthree";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "alexlarsson";
    repo = "gthree";
    rev = finalAttrs.version;
    sha256 = "09fcnjc3j21lh5fjf067wm35sb4qni4vgzing61kixnn2shy79iy";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Add option for disabling examples
    (fetchpatch {
      sha256 = "PBwLz4DLhC+7BtypVTFMFiF3hKAJeskU3XBKFHa3a84=";
      url = "https://github.com/alexlarsson/gthree/commit/75f05c40aba9d5f603d8a3c490c3406c1fe06776.patch";
    })
  ];

  nativeBuildInputs = [
    ninja
    meson
    pkg-config
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    gobject-introspection
  ];

  buildInputs = [
    libepoxy
    json-glib
  ];

  propagatedBuildInputs = [
    glib
    gtk3
    graphene
  ];

  mesonFlags = [
    "-Dgtk_doc=${if stdenv.hostPlatform.isDarwin then "false" else "true"}"
    # Data for examples is useless when the example programs are not installed.
    "-Dexamples=false"
  ];

  meta = {
    description = "GObject/GTK port of three.js";
    homepage = "https://github.com/alexlarsson/gthree";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/gthree.x86_64-darwin
  };
})
