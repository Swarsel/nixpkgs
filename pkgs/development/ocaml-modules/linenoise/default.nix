{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "linenoise";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "fxfactorial";
    repo = "ocaml-linenoise";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-yWBWMbk1anXaF4hIakTOcRZFCYmxI0xG3bHFFOAyEDA=";
  };

  propagatedBuildInputs = [ result ];
  minimalOCamlVersion = "4.06";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "OCaml bindings to linenoise";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
