{
  lib,
  stdenv,
  fetchurl,
  cmake,
  ninja,
  poppler,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poppler-data";
  version = "0.4.12";

  src = fetchurl {
    url = "https://poppler.freedesktop.org/poppler-data-${finalAttrs.version}.tar.gz";
    sha256 = "yDW2QKQM41fhuDZmqr2V7f+iTd3dSbja/2OtuFHNq3Q=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  meta = {
    inherit (poppler.meta) teams maintainers;
    description = "Encoding files for Poppler, a PDF rendering library";
    homepage = "https://poppler.freedesktop.org/";
    license = lib.licenses.free; # more free licenses combined
    platforms = lib.platforms.all;
  };
})
