{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxaw,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "autocutsel";
  version = "0.10.1";

  src = fetchurl {
    url = "https://github.com/sigmike/autocutsel/releases/download/${finalAttrs.version}/autocutsel-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-8X4G1C90lENtSyb0vgtrDaOUgcBADJZ3jkuQW2NB6xc=";
  };

  buildInputs = [
    libx11
    libxaw
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp autocutsel $out/bin/
  '';

  meta = {
    description = "Tracks changes in the server's cutbuffer and CLIPBOARD selection";
    homepage = "https://www.nongnu.org/autocutsel/";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; all;
    mainProgram = "autocutsel";
  };
})
