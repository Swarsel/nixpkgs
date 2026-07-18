{
  lib,
  stdenv,
  fetchurl,
  lzip,
  lzlib,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plzip";
  version = "1.13";

  src = fetchurl {
    url = "mirror://savannah/lzip/plzip/plzip-${finalAttrs.version}.tar.lz";
    hash = "sha256-f+AUG3Lq8ITYKq07FLOk2W3/C97698OJ91XYlIs2N8g=";
    # hash from release email
  };

  outputs = [
    "out"
    "man"
    "info"
  ];

  nativeBuildInputs = [
    lzip
    texinfo
  ];

  buildInputs = [ lzlib ];
  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "Massively parallel lossless data compressor based on the lzlib compression library";
    homepage = "https://www.nongnu.org/lzip/plzip.html";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      _360ied
    ];

    platforms = lib.platforms.all;
    mainProgram = "plzip";
  };
})
