{
  lib,
  stdenv,
  fetchurl,
  cairo,
  fetchpatch,
  gettext,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goocanvas";
  version = "2.0.4";

  src = fetchurl {
    url = "mirror://gnome/sources/goocanvas/2.0/goocanvas-${finalAttrs.version}.tar.xz";
    sha256 = "141fm7mbqib0011zmkv3g8vxcjwa7hypmq71ahdyhnj2sjvy4a67";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  # add fedora patch to fix gcc-14 build
  # https://src.fedoraproject.org/rpms/goocanvas2/tree/main
  patches = [
    (fetchpatch {
      hash = "sha256-9uqqC1uKZF9TDz5dfDTKSRCmjEiuvqkLnZ9w6U+q2TI=";
      name = "goocanvas-2.0.4-Fix-building-with-GCC-14.patch";
      url = "https://src.fedoraproject.org/rpms/goocanvas2/raw/e799612a277262a0c6bd03db10a6ee9ca7871b9c/f/goocanvas-2.0.4-Fix-building-with-GCC-14.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    gtk-doc
    python3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    cairo
    glib
  ];

  configureFlags = [
    "--disable-python"
  ];

  env = {
    PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_GIRDIR = "$(dev)/share/gir-1.0";
    PKG_CONFIG_GOBJECT_INTROSPECTION_1_0_TYPELIBDIR = "$(out)/lib/girepository-1.0";
  };

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "goocanvas_${lib.versions.major finalAttrs.version}";
      freeze = true;
      packageName = "goocanvas";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Canvas widget for GTK based on the the Cairo 2D library";
    homepage = "https://gitlab.gnome.org/Archive/goocanvas";
    license = lib.licenses.lgpl2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
