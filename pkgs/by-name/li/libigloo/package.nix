{
  lib,
  stdenv,
  fetchurl,
  icecast,
  rhash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libigloo";
  version = "0.9.5";

  src = fetchurl {
    url = "https://downloads.xiph.org/releases/igloo/libigloo-${finalAttrs.version}.tar.gz";
    hash = "sha256-6iLpEZ96IYiBD5kQDFFVxnYtRZWuITuawp5ptPC4cok=";
  };

  buildInputs = [ rhash ];
  doCheck = true;

  meta = {
    inherit (icecast.meta) maintainers;
    description = "Generic C framework used and developed by the Icecast project";
    license = lib.licenses.gpl2Only;
  };
})
