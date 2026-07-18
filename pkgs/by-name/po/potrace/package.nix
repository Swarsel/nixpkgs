{
  lib,
  stdenv,
  fetchurl,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "potrace";
  version = "1.16";

  src = fetchurl {
    url = "https://potrace.sourceforge.net/download/${finalAttrs.version}/potrace-${finalAttrs.version}.tar.gz";
    sha256 = "1k3sxgjqq0jnpk9xxys05q32sl5hbf1lbk1gmfxcrmpdgnhli0my";
  };

  buildInputs = [ zlib ];
  configureFlags = [ "--with-libpotrace" ];
  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "Tool for tracing a bitmap, which means, transforming a bitmap into a smooth, scalable image";
    homepage = "https://potrace.sourceforge.net/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.pSub ];
    platforms = lib.platforms.unix;
  };
})
