{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  ocaml,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_blob";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/johnwhitington/ppx_blob/releases/download/${finalAttrs.version}/ppx_blob-${finalAttrs.version}.tbz";
    sha256 = "sha256-8RXpCl8Qdc7cnZMKuRJx+GcOzk3uENwRR6s5uK+1cOQ=";
  };

  propagatedBuildInputs = [ ppxlib ];
  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "OCaml ppx to include binary data from a file as a string";
    homepage = "https://github.com/johnwhitington/ppx_blob";
    license = lib.licenses.unlicense;
  };
})
