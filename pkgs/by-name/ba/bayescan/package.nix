{
  lib,
  stdenv,
  fetchurl,
  llvmPackages,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bayescan";
  version = "2.1";

  src = fetchurl {
    url = "http://cmpg.unibe.ch/software/BayeScan/files/BayeScan${finalAttrs.version}.zip";
    sha256 = "0ismima8j8z0zj9yc267rpf7z90w57b2pbqzjnayhc3ab8mcbfy6";
  };

  postPatch = ''
    substituteInPlace Makefile --replace-fail "-static" "" \
                               --replace-fail "g++" "${stdenv.cc.targetPrefix}c++"
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = lib.optional stdenv.cc.isClang llvmPackages.openmp;
  env.NIX_CFLAGS_COMPILE = toString [ "-std=c++14" ];

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/doc/bayescan
    cp bayescan_${finalAttrs.version} $out/bin
    cp -r ../*pdf ../input_examples ../"R functions" $out/share/doc/bayescan
  '';

  # Disable FORTIFY_SOURCE or the binary fails with "buffer overflow"
  hardeningDisable = [ "fortify" ];
  sourceRoot = "BayeScan${finalAttrs.version}/source";

  meta = {
    description = "Detecting natural selection from population-based genetic data";
    homepage = "http://cmpg.unibe.ch/software/BayeScan";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.all;
    mainProgram = "bayescan_${finalAttrs.version}";
  };
})
