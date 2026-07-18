{
  lib,
  stdenv,
  fetchurl,
  aspell,
  autoreconfHook,
  docbook_xsl,
  enchant,
  fetchpatch,
  gtk-doc,
  gtk2,
  intltool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkspell";
  version = "2.0.16";

  src = fetchurl {
    url = "mirror://sourceforge/gtkspell/gtkspell-${finalAttrs.version}.tar.gz";
    sha256 = "00hdv28bp72kg1mq2jdz1sdw2b8mb9iclsp7jdqwpck705bdriwg";
  };

  patches = [
    # Fix build with gettext 0.25
    ./gettext-0.25.patch
    # Build with enchant 2
    # https://github.com/archlinux/svntogit-packages/tree/packages/gtkspell/trunk
    (fetchpatch {
      sha256 = "0d9409bnapwzwhnfpz3dvl6qalskqa4lzmhrmciazsypbw3ry5rf";
      url = "https://github.com/archlinux/svntogit-packages/raw/17fb30b5196db378c18e7c115f28e97b962b95ff/trunk/enchant-2.diff";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    gtk2 # GLIB_GNU_GETTEXT
    gtk-doc
    intltool
    pkg-config
  ];

  buildInputs = [
    aspell
    enchant
    gtk2
  ];

  meta = {
    description = "Word-processor-style highlighting and replacement of misspelled words";
    homepage = "https://gtkspell.sourceforge.net";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
  };
})
