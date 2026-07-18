{
  lib,
  buildDunePackage,
  coin,
  fetchzip,
  uuuu,
  yuscii,
}:

buildDunePackage (finalAttrs: {
  pname = "rosetta";
  version = "0.4.0";

  src = fetchzip {
    url = "https://github.com/mirage/rosetta/releases/download/v${finalAttrs.version}/rosetta-${finalAttrs.version}.tbz";
    hash = "sha256-LFdkwHBppDXE5q6mcDPWX1PreSVEsV9msq6rEmCWVwA=";
  };

  propagatedBuildInputs = [
    coin
    uuuu
    yuscii
  ];

  doCheck = false; # No tests.
  duneVersion = "3";

  meta = {
    description = "Universal decoder of an encoded flow (UTF-7, ISO-8859 and KOI8) to Unicode";
    homepage = "https://github.com/mirage/rosetta";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
