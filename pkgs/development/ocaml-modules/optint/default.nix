{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "optint";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/mirage/optint/releases/download/v${finalAttrs.version}/optint-${finalAttrs.version}.tbz";
    sha256 = "sha256-KVz/LBNLA4WxO6gdUAXZ+EG6QNSlAq7RDJl/I57xFHs=";
  };

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Abstract type of integer between x64 and x86 architecture";
    homepage = "https://github.com/mirage/optint";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
