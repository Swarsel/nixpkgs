{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nbench-byte";
  version = "2.2.3";

  src = fetchurl {
    url = "https://www.math.utah.edu/~mayer/linux/nbench-byte-${finalAttrs.version}.tar.gz";
    sha256 = "1b01j7nmm3wd92ngvsmn2sbw43sl9fpx4xxmkrink68fz1rx0gbj";
  };

  buildInputs = lib.optionals stdenv.hostPlatform.isGnu [
    stdenv.cc.libc.static
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    mkdir -p $out/bin
    cp nbench $out/bin
    cp NNET.DAT $out
  '';

  prePatch = ''
    substituteInPlace nbench1.h --replace-fail '"NNET.DAT"' "\"$out/NNET.DAT\"" \
      --replace-fail 'static void adjust_mid_wts();' 'static void adjust_mid_wts(int);'
    substituteInPlace sysspec.h --replace-fail "malloc.h" "stdlib.h"
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Makefile --replace-fail "-static" ""
  '';

  meta = {
    description = "Synthetic computing benchmark program";
    homepage = "https://www.math.utah.edu/~mayer/linux/bmark.html";
    maintainers = with lib.maintainers; [ bennofs ];
    platforms = lib.platforms.unix;
    mainProgram = "nbench";
  };
})
