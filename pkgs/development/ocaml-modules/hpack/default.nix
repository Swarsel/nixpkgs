{
  lib,
  fetchurl,
  angstrom,
  buildDunePackage,
  faraday,
}:

buildDunePackage (finalAttrs: {
  pname = "hpack";
  version = "0.13.0";

  src = fetchurl {
    url = "https://github.com/anmonteiro/ocaml-h2/releases/download/${finalAttrs.version}/h2-${finalAttrs.version}.tbz";
    hash = "sha256-DYm28XgXUpTnogciO+gdW4P8Mbl1Sb7DTwQyo7KoBw8=";
  };

  propagatedBuildInputs = [
    angstrom
    faraday
  ];

  # circular dependency
  doCheck = false;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "HPACK (Header Compression for HTTP/2) implementation in OCaml";
    homepage = "https://github.com/anmonteiro/ocaml-h2";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      sternenseemann
    ];
  };
})
