{
  lib,
  stdenv,
  fetchurl,
  arpack,
  blas,
  gfortran,
  lapack,
  spooles,
}:

assert (blas.isILP64 == lapack.isILP64 && blas.isILP64 == arpack.isILP64 && !blas.isILP64);

stdenv.mkDerivation (finalAttrs: {
  pname = "calculix-ccx";
  version = "2.22";

  src = fetchurl {
    url = "https://www.dhondt.de/ccx_${finalAttrs.version}.src.tar.bz2";
    hash = "sha256-OpTcx3WjH1cCKXNLNB1rBjAevcdZhj35Aci5vxhUwLw=";
  };

  patches = [
    ./calculix-ccx.patch
  ];

  postPatch = ''
    cd ccx*/src
  '';

  nativeBuildInputs = [ gfortran ];

  buildInputs = [
    arpack
    spooles
    blas
    lapack
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${spooles}/include/spooles"
    "-std=legacy"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm0755 ccx_${finalAttrs.version} $out/bin/ccx

    runHook postInstall
  '';

  meta = {
    description = "Three-dimensional structural finite element program";
    homepage = "http://www.calculix.de";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ccx";
  };
})
