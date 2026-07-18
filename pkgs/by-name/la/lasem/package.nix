{
  lib,
  stdenv,
  fetchurl,
  cairo,
  gdk-pixbuf,
  glib,
  gnome,
  gobject-introspection,
  intltool,
  libxml2,
  pango,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lasem";
  version = "0.4.4";

  src = fetchurl {
    url = "mirror://gnome/sources/lasem/${lib.versions.majorMinor finalAttrs.version}/lasem-${finalAttrs.version}.tar.xz";
    sha256 = "0fds3fsx84ylsfvf55zp65y8xqjj5n8gbhcsk02vqglivk7izw4v";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
    "doc"
    "devdoc"
  ];

  nativeBuildInputs = [
    pkg-config
    intltool
    gobject-introspection
  ];

  propagatedBuildInputs = [
    glib
    gdk-pixbuf
    libxml2
    cairo
    pango
  ];

  doCheck = true;
  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "lasem";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "SVG and MathML rendering library";
    homepage = "https://github.com/LasemProject/lasem";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "lasem-render-0.4";
  };
})
