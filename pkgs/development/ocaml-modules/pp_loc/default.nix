{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "pp_loc";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/Armael/pp_loc/releases/download/v${finalAttrs.version}/pp_loc-${finalAttrs.version}.tbz";
    hash = "sha256-L3NlBdQx6BpP6FGtMQ/ynsTNIMj9N+8FDZ5vEFC6p8s=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Quote and highlight input fragments at a given source location";
    homepage = "https://armael.github.io/pp_loc/pp_loc/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
