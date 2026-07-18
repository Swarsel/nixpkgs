{
  lib,
  stdenv,
  autoreconfHook,
  boost,
  cppunit,
  fetchgit,
  librevenge,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libepubgen";
  version = "0.1.1";

  src = fetchgit {
    url = "https://git.code.sf.net/p/libepubgen/code";
    rev = "libepubgen-${finalAttrs.version}";
    hash = "sha256-wPpU8Sfhx9GIgDmT/otT5yV4iQKm9QPZqgSBTfFcbbg=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    boost
    cppunit
    librevenge
    libxml2
  ];

  meta = {
    description = "EPUB generator for librevenge";
    homepage = "https://sourceforge.net/projects/libepubgen/";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
