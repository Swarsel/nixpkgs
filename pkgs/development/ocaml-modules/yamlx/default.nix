{
  lib,
  fetchurl,
  buildDunePackage,
  ppx_deriving,
  testo,
}:

buildDunePackage (finalAttrs: {
  pname = "yamlx";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/mjambon/yamlx/releases/download/${finalAttrs.version}/yamlx-${finalAttrs.version}.tbz";
    hash = "sha256-9pGp4XSCjMEwsUqHtwoyLBKTUdPjmYccqaU3dLkgVzg=";
  };

  propagatedBuildInputs = [ ppx_deriving ];
  doCheck = true;
  checkInputs = [ testo ];
  minimalOCamlVersion = "4.14";

  meta = {
    description = "Pure-OCaml YAML 1.2 parser with a lossless, comment-preserving AST";
    homepage = "https://github.com/mjambon/yamlx";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
