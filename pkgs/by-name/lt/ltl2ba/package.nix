{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ltl2ba";
  version = "1.3";

  src = fetchurl {
    url = "http://www.lsv.ens-cachan.fr/~gastin/ltl2ba/ltl2ba-${finalAttrs.version}.tar.gz";
    sha256 = "1bz9gjpvby4mnvny0nmxgd81rim26mqlcnjlznnxxk99575pfa4i";
  };

  preConfigure = ''
    substituteInPlace Makefile \
    --replace "CC=gcc" ""
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv ltl2ba $out/bin
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Fast translation from LTL formulae to Buchi automata";
    homepage = "http://www.lsv.ens-cachan.fr/~gastin/ltl2ba";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "ltl2ba";
  };
})
