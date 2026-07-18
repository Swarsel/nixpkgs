{
  lib,
  stdenv,
  fetchurl,
  lzo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lzop";
  version = "1.04";

  src = fetchurl {
    url = "https://www.lzop.org/download/lzop-${finalAttrs.version}.tar.gz";
    sha256 = "0h9gb8q7y54m9mvy3jvsmxf21yx8fc3ylzh418hgbbv0i8mbcwky";
  };

  buildInputs = [ lzo ];

  meta = {
    description = "Fast file compressor";
    homepage = "http://www.lzop.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lzop";
  };
})
