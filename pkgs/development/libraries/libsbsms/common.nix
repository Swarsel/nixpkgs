{
  lib,
  stdenv,
  fetchurl,
  homepage,
  pname,
  replaceVars,
  sha256,
  url,
  version,
}:

stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    inherit url sha256;
  };

  patches = [
    # Fix building on platforms other than x86
    (replaceVars ./configure.patch {
      msse = lib.optionalString stdenv.hostPlatform.isx86_64 "-msse";
    })
  ];

  doCheck = true;

  meta = {
    inherit homepage;
    description = "Subband sinusoidal modeling library for time stretching and pitch scaling audio";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
