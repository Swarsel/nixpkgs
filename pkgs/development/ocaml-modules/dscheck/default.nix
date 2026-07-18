{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  containers,
  oseq,
}:

buildDunePackage (finalAttrs: {
  pname = "dscheck";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/ocaml-multicore/dscheck/releases/download/${finalAttrs.version}/dscheck-${finalAttrs.version}.tbz";
    hash = "sha256-9Rm2DmdvVeCkgAWCvkYdQTj94wmU7JkY8UI3fReIaG0=";
  };

  propagatedBuildInputs = [
    containers
    oseq
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  minimalOCamlVersion = "5.0";

  meta = {
    description = "Traced atomics";
    homepage = "https://github.com/ocaml-multicore/dscheck";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
