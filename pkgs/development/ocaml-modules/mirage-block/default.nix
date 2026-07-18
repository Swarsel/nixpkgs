{
  lib,
  fetchurl,
  buildDunePackage,
  cstruct,
  fmt,
  lwt,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-block";
  version = "3.0.2";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-block/releases/download/v${finalAttrs.version}/mirage-block-${finalAttrs.version}.tbz";
    hash = "sha256-UALUfeL0G1mfSsLgAb/HpQ6OV12YtY+GUOYG6yhUwAI=";
  };

  propagatedBuildInputs = [
    cstruct
    lwt
    fmt
  ];

  duneVersion = "3";

  meta = {
    description = "Block signatures and implementations for MirageOS";
    homepage = "https://github.com/mirage/mirage-block";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
