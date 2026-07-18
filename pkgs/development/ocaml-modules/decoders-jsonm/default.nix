{
  lib,
  buildDunePackage,
  containers,
  decoders,
  jsonm,
  ounit2,
}:

buildDunePackage (finalAttrs: {
  # sub-package built separately from the same source
  inherit (decoders) src version;
  pname = "decoders-jsonm";

  propagatedBuildInputs = [
    decoders
    jsonm
  ];

  doCheck = true;

  checkInputs = [
    containers
    ounit2
  ];

  minimalOCamlVersion = "4.03.0";

  meta = {
    description = "Jsonm backend for decoders";
    homepage = "https://github.com/mattjbray/ocaml-decoders";
    changelog = "https://github.com/mattjbray/ocaml-decoders/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
})
