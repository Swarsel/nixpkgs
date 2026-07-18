{
  lib,
  stdenv,
  ecm,
  fetchsvn,
  gmp,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "msieve";
  version = "1056";

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/msieve/code/trunk";
    rev = finalAttrs.version;
    hash = "sha256-6ErVn4pYPMG5VFjOQURLsHNpN0pGdp55+rjY8988onU=";
  };

  patches = [ ./savefile_t-pointer-type.patch ];

  buildInputs = [
    zlib
    gmp
    ecm
  ];

  # Doesn't hurt Linux but lets clang-based platforms like Darwin work fine too
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "all"
  ];

  env.ECM = if ecm == null then "0" else "1";

  installPhase = ''
    mkdir -p $out/bin/
    cp msieve $out/bin/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "C library implementing a suite of algorithms to factor large integers";
    homepage = "http://msieve.sourceforge.net/";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.roconnor ];
    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    mainProgram = "msieve";
  };
})
