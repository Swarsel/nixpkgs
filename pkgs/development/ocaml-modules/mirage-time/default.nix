{
  lib,
  fetchurl,
  buildDunePackage,
  lwt,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-time";
  version = "3.0.0";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-time/releases/download/v${finalAttrs.version}/mirage-time-v${finalAttrs.version}.tbz";
    hash = "sha256-DUCUm1jix+i3YszIzgZjRQRiM8jJXQ49F6JC/yicvXw=";
  };

  propagatedBuildInputs = [ lwt ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Time operations for MirageOS";
    homepage = "https://github.com/mirage/mirage-time";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
