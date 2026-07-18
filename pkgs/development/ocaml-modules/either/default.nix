{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "either";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/mirage/either/releases/download/${finalAttrs.version}/either-${finalAttrs.version}.tbz";
    hash = "sha256-v2dN4zEt7ntyFfB98eipbrPWeRZLipGM3ZW42X5QWIQ=";
  };

  meta = {
    description = "Compatibility Either module";
    homepage = "https://github.com/mirage/either";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
