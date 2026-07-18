{
  lib,
  fetchurl,
  alcotest,
  alcotest-lwt,
  bigstringaf,
  buildDunePackage,
  cstruct,
  ke,
  logs,
  lwt,
  mirage-flow,
}:

buildDunePackage (finalAttrs: {
  pname = "mimic";
  version = "0.0.9";

  src = fetchurl {
    url = "https://github.com/dinosaure/mimic/releases/download/${finalAttrs.version}/mimic-${finalAttrs.version}.tbz";
    hash = "sha256-lU3xzrVIqSKnhUQIhaXRamr39zXWw3DtNdM5EUtp4p8=";
  };

  propagatedBuildInputs = [
    lwt
    mirage-flow
    logs
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    alcotest-lwt
    bigstringaf
    cstruct
    ke
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Simple protocol dispatcher";
    homepage = "https://github.com/mirage/ocaml-git";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
