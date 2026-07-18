{
  lib,
  fetchurl,
  buildDunePackage,
  mtime,
  version ? "5.2.0",
}:

buildDunePackage {
  inherit version;
  pname = "mirage-mtime";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-mtime/releases/download/v${version}/mirage-mtime-${version}.tbz";
    hash = "sha256-kaBDUqQF1SFecku85iRnX9ji18TjbTIlz4BlRuRAib8=";
  };

  propagatedBuildInputs = [
    mtime
  ];

  meta = {
    description = "Monotonic time for MirageOS";
    homepage = "https://github.com/mirage/mirage-mtime";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
