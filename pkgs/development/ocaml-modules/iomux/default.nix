{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  dune-configurator,
}:

buildDunePackage (finalAttrs: {
  pname = "iomux";
  version = "0.4";

  src = fetchurl {
    url = "https://github.com/haesbaert/ocaml-iomux/releases/download/v${finalAttrs.version}/iomux-${finalAttrs.version}.tbz";
    hash = "sha256-Hjk/rlWUdoSMXHBSUHaxEHDoBqVJ7rrghLBGqXcrqzU=";
  };

  buildInputs = [
    dune-configurator
  ];

  checkInputs = [
    alcotest
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "IO Multiplexers for OCaml";
    homepage = "https://github.com/haesbaert/ocaml-iomux";
    license = with lib.licenses; [ isc ];
    maintainers = with lib.maintainers; [ toastal ];
  };
})
