{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-clock";
  version = "4.2.0";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-clock/releases/download/v${finalAttrs.version}/mirage-clock-${finalAttrs.version}.tbz";
    hash = "sha256-+hfRXVviPHm6dB9ffLiO1xEt4WpEEM6oHHG5gIaImEc=";
  };

  minimalOCamlVersion = "4.06";

  meta = {
    description = "Libraries and module types for portable clocks";
    homepage = "https://github.com/mirage/mirage-clock";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
