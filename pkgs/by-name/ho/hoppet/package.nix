{
  lib,
  stdenv,
  fetchurl,
  gfortran,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hoppet";
  version = "1.2.0";

  src = fetchurl {
    url = "https://hoppet.hepforge.org/downloads/hoppet-${finalAttrs.version}.tgz";
    sha256 = "0j7437rh4xxbfzmkjr22ry34xm266gijzj6mvrq193fcsfzipzdz";
  };

  nativeBuildInputs = [
    perl
    gfortran
  ];

  preConfigure = ''
    patchShebangs .
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Higher Order Perturbative Parton Evolution Toolkit";
    homepage = "https://hoppet.hepforge.org";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
    mainProgram = "hoppet-config";
  };
})
