{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libaal";
  version = "1.0.7";

  src = fetchurl {
    url = "mirror://sourceforge/reiser4/libaal-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-fIVohp2PVCaNaQRVJ4zfW8mukiiqM3BgF8Vwu9qrmJE=";
  };

  preInstall = ''
    substituteInPlace Makefile --replace ./run-ldconfig true
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Support library for Reiser4";
    homepage = "http://www.namesys.com/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
  };
})
