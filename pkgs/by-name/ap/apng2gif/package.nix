{
  lib,
  stdenv,
  fetchzip,
  libpng,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apng2gif";
  version = "1.8";

  src = fetchzip {
    url = "mirror://sourceforge/apng2gif/apng2gif-${finalAttrs.version}-src.zip";
    hash = "sha256-qX8gmE0Lu2p15kL0y6cmX/bI0uk5Ehfi8ygt07BbgmU=";
    stripRoot = false;
  };

  # Remove bundled libs
  postPatch = ''
    rm -r libpng zlib
  '';

  buildInputs = [
    libpng
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}c++" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 apng2gif $out/bin/apng2gif
    runHook postInstall
  '';

  meta = {
    description = "Simple program that converts APNG files to animated GIF format";
    homepage = "https://apng2gif.sourceforge.net/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
  };
})
