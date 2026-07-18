{
  lib,
  stdenv,
  fetchzip,
  libpng,
  zlib,
  zopfli,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apngopt";
  version = "1.4";

  src = fetchzip {
    url = "mirror://sourceforge/apng/apngopt-${finalAttrs.version}-src.zip";
    hash = "sha256-MAqth5Yt7+SabY6iEgSFcaBmuHvA0ZkNdXSgvhKao1Y=";
    stripRoot = false;
  };

  patches = [
    ./remove-7z.patch
  ];

  # Remove bundled libs
  postPatch = ''
    rm -r 7z libpng zlib zopfli
  '';

  buildInputs = [
    libpng
    zlib
    zopfli
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}c++" ];

  preBuild = ''
    buildFlagsArray+=("LIBS=-lzopfli -lstdc++ -lpng -lz")
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 apngopt $out/bin/apngopt
    runHook postInstall
  '';

  meta = {
    description = "Optimizes APNG animations";
    homepage = "https://sourceforge.net/projects/apng/";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
  };
})
