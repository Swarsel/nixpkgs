{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "owee";
  version = "0.8";

  src = fetchurl {
    url = "https://github.com/let-def/owee/releases/download/v${finalAttrs.version}/owee-${finalAttrs.version}.tbz";
    hash = "sha256-Bk9iRfWZXV0vTx+cbSmS4v2+Pd4ygha67Hz6vUhXlA0=";
  };

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Experimental OCaml library to work with DWARF format";
    homepage = "https://github.com/let-def/owee/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vbgl
      alizter
    ];
  };
})
