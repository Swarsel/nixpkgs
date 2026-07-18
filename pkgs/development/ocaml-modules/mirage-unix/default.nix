{
  lib,
  fetchurl,
  buildDunePackage,
  duration,
  lwt,
  mirage-runtime,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-unix";
  version = "5.0.1";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-unix/releases/download/v${finalAttrs.version}/mirage-unix-${finalAttrs.version}.tbz";
    hash = "sha256-U1oLznUDBcJLcVygfSiyl5qRLDM27cm/WrjT0vSGhPg=";
  };

  propagatedBuildInputs = [
    lwt
    duration
    mirage-runtime
  ];

  doCheck = true;
  duneVersion = "3";

  meta = {
    description = "Unix core platform libraries for MirageOS";
    homepage = "https://github.com/mirage/mirage-unix";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
