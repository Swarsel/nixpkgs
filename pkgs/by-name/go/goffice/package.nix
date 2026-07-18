{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  cairo,
  glib,
  gnome,
  gnumeric,
  gtk-doc,
  gtk3,
  intltool,
  lasem,
  libgsf,
  librsvg,
  libxml2,
  libxslt,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goffice";
  version = "0.10.61";

  src = fetchurl {
    url = "mirror://gnome/sources/goffice/${lib.versions.majorMinor finalAttrs.version}/goffice-${finalAttrs.version}.tar.xz";
    hash = "sha256-VYWX/Zylm5P/VidQIY0efqjsPI0O1qXMCWqnFe+QmhU=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    pkg-config
    intltool
    autoreconfHook
    gtk-doc
    glib # for glib-genmarshal
  ];

  buildInputs = [
    libxslt
    librsvg
  ];

  propagatedBuildInputs = [
    glib
    gtk3
    libxml2
    cairo
    pango
    libgsf
    lasem
  ];

  enableParallelBuilding = true;

  passthru = {
    tests = {
      inherit gnumeric;
    };

    updateScript = gnome.updateScript {
      packageName = "goffice";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Glib/GTK set of document centric objects and utilities";

    longDescription = ''
      There are common operations for document centric applications that are
      conceptually simple, but complex to implement fully: plugins, load/save
      documents, undo/redo.
    '';

    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
