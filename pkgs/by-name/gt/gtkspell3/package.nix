{
  lib,
  stdenv,
  fetchurl,
  aspell,
  enchant,
  gobject-introspection,
  gtk3,
  intltool,
  isocodes,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkspell";
  version = "3.0.10";

  src = fetchurl {
    url = "mirror://sourceforge/gtkspell/gtkspell3-${finalAttrs.version}.tar.xz";
    sha256 = "0cjp6xdcnzh6kka42w9g0w2ihqjlq8yl8hjm9wsfnixk6qwgch5h";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    intltool
    gobject-introspection
    vala
  ];

  buildInputs = [
    aspell
    gtk3
    enchant
    isocodes
  ];

  propagatedBuildInputs = [ enchant ];

  configureFlags = [
    "--enable-introspection"
    "--enable-vala"
  ];

  meta = {
    description = "Word-processor-style highlighting GtkTextView widget";
    homepage = "https://gtkspell.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
