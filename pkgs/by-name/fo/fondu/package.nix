{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fondu";
  version = "060102";

  src = fetchurl {
    url = "https://fondu.sourceforge.net/fondu_src-${finalAttrs.version}.tgz";
    sha256 = "152prqad9jszjmm4wwqrq83zk13ypsz09n02nrk1gg0fcxfm7fr2";
  };

  makeFlags = [ "DESTDIR=$(out)" ];

  postConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Makefile --replace /System/Library/Frameworks/CoreServices.framework/CoreServices "-framework CoreServices"
  '';

  hardeningDisable = [ "fortify" ];

  meta = {
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
})
