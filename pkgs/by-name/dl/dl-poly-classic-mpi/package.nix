{
  lib,
  stdenv,
  fetchurl,
  gfortran,
  mpi,
}:

stdenv.mkDerivation {
  pname = "DL_POLY_Classic";
  version = "1.10";

  src = fetchurl {
    url = "https://ccpforge.cse.rl.ac.uk/gf/download/frsrelease/574/8924/dl_class_1.10.tar.gz";
    sha256 = "1r76zvln3bwycxlmqday0sqzv5j260y7mdh66as2aqny6jzd5ld7";
  };

  nativeBuildInputs = [ gfortran ];
  buildInputs = [ mpi ];
  # https://gitlab.com/DL_POLY_Classic/dl_poly/-/blob/master/README
  env.NIX_CFLAGS_COMPILE = "-fallow-argument-mismatch";

  buildPhase = ''
    make dlpoly
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -v ../execute/DLPOLY.X $out/bin
  '';

  configurePhase = ''
    runHook preConfigure

    cd source
    cp -v ../build/MakePAR Makefile

    runHook postConfigure
  '';

  meta = {
    description = "DL_POLY Classic is a general purpose molecular dynamics simulation package";
    homepage = "https://www.ccp5.ac.uk/DL_POLY_C";
    license = lib.licenses.bsdOriginal;
    maintainers = [ lib.maintainers.costrouc ];
    platforms = lib.platforms.unix;
    mainProgram = "DLPOLY.X";
  };
}
