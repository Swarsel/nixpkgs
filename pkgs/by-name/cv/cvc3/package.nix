{
  lib,
  fetchurl,
  bison,
  flex,
  gccStdenv,
  gmp,
  perl,
}:
let
  gmp' = lib.overrideDerivation gmp (_: {
    dontDisableStatic = true;
  });
  stdenv = gccStdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cvc3";
  version = "2.4.1";

  src = fetchurl {
    url = "https://cs.nyu.edu/acsys/cvc3/releases/${finalAttrs.version}/cvc3-${finalAttrs.version}.tar.gz";
    hash = "sha256-1VsdYAbPusP21MCGlkVYkCw+0O+masSZz7IZPz7krPc=";
  };

  patches = [ ./cvc3-2.4.1-gccv6-fix.patch ];

  postPatch = ''
    sed -e "s@ /bin/bash@bash@g" -i Makefile.std
    find . -exec sed -e "s@/usr/bin/perl@${perl}/bin/perl@g" -i '{}' ';'

    # bison 3.7 workaround
    for f in parsePL parseLisp parsesmtlib parsesmtlib2 ; do
      ln -s ../parser/''${f}_defs.h src/include/''${f}.hpp
    done
  '';

  buildInputs = [
    gmp'
    flex
    bison
    perl
  ];

  # fails to configure on darwin due to gmp not found
  configureFlags = [
    "LIBS=-L${gmp'}/lib"
    "CXXFLAGS=-I${gmp'.dev}/include"
  ];

  passthru = {
    updateInfo = {
      downloadPage = "https://cs.nyu.edu/acsys/cvc3/download.html";
    };
  };

  meta = {
    description = "Prover for satisfiability modulo theory (SMT)";
    homepage = "https://cs.nyu.edu/acsys/cvc3/index.html";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "cvc3";
  };
})
