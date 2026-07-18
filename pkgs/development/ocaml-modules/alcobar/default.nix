{
  lib,
  fetchurl,
  afl-persistent,
  alcotest,
  buildDunePackage,
  calendar,
  cmdliner,
  fpath,
  ocaml,
  pprint,
  uucp,
  uunf,
}:

buildDunePackage (finalAttrs: {
  pname = "alcobar";
  version = "0.3.1";

  src = fetchurl {
    url = "https://github.com/samoht/alcobar/releases/download/v${finalAttrs.version}/alcobar-${finalAttrs.version}.tbz";
    hash = "sha256-V2UnvLrtf+XXkp7uFlrIpxg6+fZqwhCS/J7C3Nw+eVU=";
  };

  propagatedBuildInputs = [
    afl-persistent
    alcotest
    cmdliner
  ];

  doCheck = lib.versionAtLeast ocaml.version "5.0";

  checkInputs = [
    calendar
    fpath
    pprint
    uucp
    uunf
  ];

  __structuredAttrs = true;
  minimalOCamlVersion = "4.10";

  meta = {
    description = "Crowbar with an Alcotest-compatible API";
    homepage = "https://github.com/samoht/alcobar";
    changelog = "https://github.com/samoht/alcobar/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vog ];
  };
})
