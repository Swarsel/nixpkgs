{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  decompress,
  stdlib-shims,
}:

buildDunePackage (finalAttrs: {
  pname = "imagelib";
  version = "20221222";

  src = fetchurl {
    url = "https://github.com/rlepigre/ocaml-imagelib/releases/download/${finalAttrs.version}/imagelib-${finalAttrs.version}.tbz";
    hash = "sha256-BQ2TVxGlpc6temteK84TKXpx0MtHZSykL/TjKN9xGP0=";
  };

  propagatedBuildInputs = [
    decompress
    stdlib-shims
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Image formats such as PNG and PPM in OCaml";
    homepage = "https://github.com/rlepigre/ocaml-imagelib";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "imagetool";
  };
})
