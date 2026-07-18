{
  lib,
  stdenv,
  fetchurl,
  libpng,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pngnq";
  version = "1.1";

  src = fetchurl {
    url = "mirror://sourceforge/pngnq/pngnq-${finalAttrs.version}.tar.gz";
    sha256 = "1qmnnl846agg55i7h4vmrn11lgb8kg6gvs8byqz34bdkjh5gwiy1";
  };

  patches = [
    ./missing-includes.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpng
    zlib
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=incompatible-pointer-types"
  ];

  meta = {
    description = "PNG quantizer";
    homepage = "https://pngnq.sourceforge.net/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
  };
})
