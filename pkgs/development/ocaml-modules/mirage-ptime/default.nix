{
  lib,
  fetchurl,
  buildDunePackage,
  ptime,
  version ? "5.2.0",
}:

buildDunePackage {
  inherit version;
  pname = "mirage-ptime";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-ptime/releases/download/v${version}/mirage-ptime-${version}.tbz";
    hash = "sha256-YOWpJrfQKG9khCwPb5lZXtf+fip4N0B1AAn2Y9zRLyg=";
  };

  propagatedBuildInputs = [ ptime ];

  meta = {
    description = "POSIX clock for MirageOS";
    homepage = "https://github.com/mirage/mirage-ptime";
    changelog = "https://raw.githubusercontent.com/mirage/mirage-ptime/refs/tags/v${version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
