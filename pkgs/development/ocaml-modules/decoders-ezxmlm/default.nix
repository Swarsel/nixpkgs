{
  lib,
  buildDunePackage,
  containers,
  decoders,
  ezxmlm,
}:

buildDunePackage (finalAttrs: {
  # sub-package built separately from the same source
  inherit (decoders) src version;
  pname = "decoders-ezxmlm";

  propagatedBuildInputs = [
    decoders
    ezxmlm
  ];

  doCheck = true;

  checkInputs = [
    containers
  ];

  minimalOCamlVersion = "4.03.0";

  meta = {
    description = "Ezxmlm backend for decoders";
    homepage = "https://github.com/mattjbray/ocaml-decoders";
    changelog = "https://github.com/mattjbray/ocaml-decoders/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
})
