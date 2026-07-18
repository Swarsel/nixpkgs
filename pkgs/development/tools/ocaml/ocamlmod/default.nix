{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  ounit2,
}:

buildDunePackage (finalAttrs: {
  pname = "ocamlmod";
  version = "0.1.1";

  src = fetchurl {
    url = "https://github.com/gildor478/ocamlmod/releases/download/v${finalAttrs.version}/ocamlmod-${finalAttrs.version}.tbz";
    hash = "sha256-qMG+y/iS+L4qtKiJX01pTTAdQuGLoIA+so1fqY9bm8o=";
  };

  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ ounit2 ];
  dontStrip = true;
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Generate OCaml modules from source files";
    homepage = "https://github.com/gildor478/ocamlmod";
    license = lib.licenses.WITH lib.licenses.lgpl21Only lib.licenses.ocamlLgplLinkingException;
    mainProgram = "ocamlmod";
  };
})
