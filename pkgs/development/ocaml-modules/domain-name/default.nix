{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "domain-name";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/hannesm/domain-name/releases/download/v${finalAttrs.version}/domain-name-${finalAttrs.version}.tbz";
    hash = "sha256-nseuLCJ3LBULhM+j8h2b8l+uFKeW8x4g31LYb0ZJnYk=";
  };

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "RFC 1035 Internet domain names";
    homepage = "https://github.com/hannesm/domain-name";
    changelog = "https://github.com/hannesm/domain-name/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
