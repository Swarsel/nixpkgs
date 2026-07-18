{
  lib,
  stdenv,
  fetchFromGitLab,
  cunit,
  docbook_xsl,
  doxygen,
  glib,
  gobject-introspection,
  gtk-doc,
  meson,
  ninja,
  pkg-config,
  sane-backends,
  vala,
  valgrind,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libinsane";
  version = "1.0.10";

  src = fetchFromGitLab {
    owner = "OpenPaperwork";
    repo = "libinsane";
    rev = finalAttrs.version;
    sha256 = "sha256-2BLg8zB0InPJqK9JypQIMVXIJndo9ZuNB4OeOAo/Hsc=";
    domain = "gitlab.gnome.org";
    group = "World";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    doxygen
    gtk-doc
    docbook_xsl
    gobject-introspection
    vala
  ];

  buildInputs = [
    sane-backends
    glib
  ];

  doCheck = true;

  nativeCheckInputs = [
    cunit
    valgrind
  ];

  meta = {
    description = "Crossplatform access to image scanners (paper eaters only)";
    homepage = "https://openpaper.work/en/projects/";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.symphorien ];
  };
})
