{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "randomconv";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/hannesm/randomconv/releases/download/v${finalAttrs.version}/randomconv-${finalAttrs.version}.tbz";
    hash = "sha256-sxce3wfjQaRGj5L/wh4qiGO4LtXDb3R3zJja8F1bY+o=";
  };

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Convert from random bytes to random native numbers";
    homepage = "https://github.com/hannesm/randomconv";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
