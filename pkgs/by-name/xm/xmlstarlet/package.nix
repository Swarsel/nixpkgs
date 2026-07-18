{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  libxml2,
  libxslt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xmlstarlet";
  version = "1.6.1";

  src = fetchurl {
    url = "mirror://sourceforge/xmlstar/xmlstarlet-${finalAttrs.version}.tar.gz";
    sha256 = "1jp737nvfcf6wyb54fla868yrr39kcbijijmjpyk4lrpyg23in0m";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-XEk7aFOdrzdec1j2ffERJQbLH0AUNJA52QwA9jf4XWA=";
      name = "0001-Fix-build-with-libxml2-2.12.patch";
      url = "https://sourceforge.net/p/xmlstar/patches/_discuss/thread/890e29655a/66ca/attachment/0001-Fix-build-with-libxml2-2.12.patch";
    })
    (fetchurl {
      hash = "sha256-zHkUQsrhPLWI3kdfCITbcixpBmDRmxSM2Viz5R+8q5E=";
      name = "libxml-2.14.patch";
      url = "https://github.com/termux/termux-packages/raw/39135f3f1190268d127b998c2c6040d9af611ba5/packages/xmlstarlet/libxml2-2.14-attribute-unused.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libxml2
    libxslt
  ];

  preConfigure = ''
    export LIBXSLT_PREFIX=${libxslt.dev}
    export LIBXML_PREFIX=${libxml2.dev}
    export LIBXSLT_LIBS=$($PKG_CONFIG --libs libxslt libexslt)
    export LIBXML_LIBS=$($PKG_CONFIG --libs libxml-2.0)
  '';

  postInstall = ''
    ln -s xml $out/bin/xmlstarlet
  '';

  meta = {
    description = "Command line tool for manipulating and querying XML data";
    homepage = "https://xmlstar.sourceforge.net/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "xmlstarlet";
  };
})
