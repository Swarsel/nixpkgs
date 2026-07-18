{
  lib,
  stdenv,
  fetchurl,
  freetype,
  fribidi,
  harfbuzz,
  libiconv,
  pkg-config,
  yasm,
  fontconfig ? null, # fontconfig support
  fontconfigSupport ? true,
  largeTilesSupport ? false, # Use larger tiles in the rasterizer
}:

assert fontconfigSupport -> fontconfig != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "libass";
  version = "0.17.4";

  src = fetchurl {
    url = "https://github.com/libass/libass/releases/download/${finalAttrs.version}/libass-${finalAttrs.version}.tar.xz";
    hash = "sha256-ePEXm4ONAl6cJuj+8z+AkvZWEURP+hv8DPrGozURoFo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    pkg-config
    yasm
  ];

  buildInputs = [
    freetype
    fribidi
    harfbuzz
  ]
  ++ lib.optional fontconfigSupport fontconfig;

  configureFlags = [
    (lib.enableFeature fontconfigSupport "fontconfig")
    (lib.enableFeature largeTilesSupport "large-tiles")
  ];

  meta = {
    description = "Portable ASS/SSA subtitle renderer";
    homepage = "https://github.com/libass/libass";
    license = lib.licenses.isc;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
