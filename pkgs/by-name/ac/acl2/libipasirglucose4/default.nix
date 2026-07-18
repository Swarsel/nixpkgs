{
  lib,
  stdenv,
  fetchurl,
  unzip,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libipasirglucose4";
  # This library has no version number AFAICT (beyond generally being based on
  # Glucose 4.x), but it was submitted to the 2017 SAT competition so let's use
  # that as the version number, I guess.
  version = "2017";

  src = fetchurl {
    url = "https://baldur.iti.kit.edu/sat-competition-2017/solvers/incremental/glucose-ipasir.zip";
    hash = "sha256-svGDbCLlPNCg1skHycV9cRS1zecasZodgo3v5Jt6kHU=";
  };

  patches = [ ./0001-Support-shared-library-build.patch ];
  nativeBuildInputs = [ unzip ];
  buildInputs = [ zlib ];
  makeFlags = [ "CXX=${stdenv.cc.targetPrefix}c++" ];

  postBuild = ''
    $CXX -shared -o ${finalAttrs.libname} \
        ${lib.optionalString (!stdenv.cc.isClang) "-Wl,-soname,${finalAttrs.libname}"} \
        ipasirglucoseglue.o libipasirglucose4.a
  '';

  installPhase = ''
    install -D ${finalAttrs.libname} $out/lib/${finalAttrs.libname}
  '';

  libname = finalAttrs.pname + stdenv.hostPlatform.extensions.sharedLibrary;
  sourceRoot = "sat/glucose4";

  meta = {
    description = "Shared library providing IPASIR interface to the Glucose SAT solver";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kini ];
    platforms = lib.platforms.unix;
  };
})
