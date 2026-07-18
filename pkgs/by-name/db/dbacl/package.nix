{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dbacl";
  version = "1.14";

  src = fetchurl {
    url = "https://www.lbreyer.com/gpl/dbacl-${finalAttrs.version}.tar.gz";
    sha256 = "0224g6x71hyvy7jikfxmgcwww1r5lvk0jx36cva319cb9nmrbrq7";
  };

  meta = {
    longDescription = "a digramic Bayesian classifier for text recognition.";
    homepage = "https://dbacl.sourceforge.net/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
