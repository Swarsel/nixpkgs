{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libosip2";
  version = "5.3.1";

  src = fetchurl {
    url = "mirror://gnu/osip/libosip2-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-/oL+hBYIJmrBWlwRGCFtoAxVTVAG4odaisN1Kx5q3Hk=";
  };

  meta = {
    description = "GNU oSIP library, an implementation of the Session Initiation Protocol (SIP)";
    homepage = "https://www.gnu.org/software/osip/";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.all;
  };
})
