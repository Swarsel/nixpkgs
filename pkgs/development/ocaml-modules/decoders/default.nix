{
  lib,
  fetchurl,
  buildDunePackage,
  containers,
}:

buildDunePackage (finalAttrs: {
  pname = "decoders";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/mattjbray/ocaml-decoders/releases/download/v${finalAttrs.version}/decoders-${finalAttrs.version}.tbz";
    hash = "sha256-R/55xBAtD3EO/zzq7zExANnfPHlFg00884o5dCpXNZc=";
  };

  doCheck = true;

  checkInputs = [
    containers
  ];

  minimalOCamlVersion = "4.03.0";

  meta = {
    description = "Elm-inspired decoders for Ocaml";
    homepage = "https://github.com/mattjbray/ocaml-decoders";
    changelog = "https://github.com/mattjbray/ocaml-decoders/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
})
