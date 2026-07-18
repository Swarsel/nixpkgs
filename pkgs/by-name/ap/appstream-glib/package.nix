{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  docbook_xml_dtd_42,
  docbook_xsl,
  fontconfig,
  freetype,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gperf,
  gtk-doc,
  gtk3,
  json-glib,
  libarchive,
  libuuid,
  libxslt,
  meson,
  ninja,
  pkg-config,
  pngquant,
  replaceVars,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "appstream-glib";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "appstream-glib";
    tag = "appstream_glib_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-GjXrYV+EBduhG88LaxQWICKuUDJeeotcZgqgaG0/dqo=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "installedTests"
  ];

  patches = [
    (replaceVars ./paths.patch {
      pngquant = "${pngquant}/bin/pngquant";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    docbook_xml_dtd_42
    docbook_xsl
    gettext
    gobject-introspection
    gperf
    gtk-doc
    libxslt
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    json-glib
    libarchive
    curl
    libuuid
  ];

  propagatedBuildInputs = [
    glib
    gdk-pixbuf
  ];

  mesonFlags = [
    "-Drpm=false"
    "-Ddep11=false"
  ];

  doCheck = false; # fails at least 1 test

  postInstall = ''
    moveToOutput "share/installed-tests" "$installedTests"
  '';

  __structuredAttrs = true;
  outputBin = "dev";

  meta = {
    description = "Objects and helper methods to read and write AppStream metadata";
    homepage = "https://people.freedesktop.org/~hughsient/appstream-glib/";
    changelog = "https://github.com/hughsie/appstream-glib/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
