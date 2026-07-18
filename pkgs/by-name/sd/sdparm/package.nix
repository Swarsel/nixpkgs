{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdparm";
  version = "1.12";

  src = fetchurl {
    url = "https://sg.danny.cz/sg/p/sdparm-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-xMnvr9vrZi4vlxJwfsSQkyvU0BC7ESmueplSZUburb4=";
  };

  outputs = [
    "out"
    "man"
  ];

  meta = {
    description = "Utility to access SCSI device parameters";
    homepage = "http://sg.danny.cz/sg/sdparm.html";
    license = lib.licenses.bsd3;
    platforms = with lib.platforms; linux;
  };
})
