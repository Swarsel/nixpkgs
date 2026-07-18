{
  lib,
  fetchurl,
  fetchpatch,
  gccStdenv,
  ncurses,
  zlib,
}:

let
  stdenv = gccStdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "aewan";
  version = "1.0.01";

  src = fetchurl {
    url = "mirror://sourceforge/aewan/aewan-${finalAttrs.version}.tar.gz";
    sha256 = "5266dec5e185e530b792522821c97dfa5f9e3892d0dca5e881d0c30ceac21817";
  };

  patches = [
    # Pull patch pending upstream inclusion:
    #  https://sourceforge.net/p/aewan/bugs/13/
    (fetchpatch {
      # patch is in CVS diff format, add 'a/' prefix
      extraPrefix = "";
      sha256 = "0pgpk1l3d6d5y37lvvavipwnmv9gmpfdy21jkz6baxhlkgf43r4p";
      url = "https://sourceforge.net/p/aewan/bugs/13/attachment/aewan-cvs-ncurses-6.3.patch";
    })
    # https://sourceforge.net/p/aewan/bugs/14/
    (fetchpatch {
      sha256 = "sha256-NlnsOe/OCMXCrehBq20e0KOMcWt5rUv9fIvu9eoOMqw=";
      url = "https://sourceforge.net/p/aewan/bugs/14/attachment/aewan-1.0.01-fix-incompatible-function-pointer-types.patch";
    })
    # https://sourceforge.net/p/aewan/bugs/16/
    (fetchpatch {
      # patch is in CVS diff format, add 'a/' prefix
      extraPrefix = "";
      sha256 = "sha256-RWFJRDaYoiQySkB2L09JHSX90zgIJ9q16IrPhg03Ruc=";
      url = "https://sourceforge.net/p/aewan/bugs/16/attachment/implicit-function-declaration.patch";
    })
  ];

  buildInputs = [
    zlib
    ncurses
  ];

  meta = {
    description = "Ascii-art Editor Without A Name";
    homepage = "https://aewan.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
