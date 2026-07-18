{
  lib,
  buildDunePackage,
  containers,
  decoders,
  ezjsonm,
  ounit2,
}:

buildDunePackage (finalAttrs: {
  # sub-package built separately from the same source
  inherit (decoders) src version;
  pname = "decoders-ezjsonm";

  propagatedBuildInputs = [
    decoders
    ezjsonm
  ];

  doCheck = true;

  checkInputs = [
    containers
    ounit2
  ];

  minimalOCamlVersion = "4.03.0";

  meta = {
    description = "Ezjsonm backend for decoders";
    homepage = "https://github.com/mattjbray/ocaml-decoders";
    changelog = "https://github.com/mattjbray/ocaml-decoders/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
})
