{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  type_eq,
}:

buildDunePackage rec {
  pname = "type_id";
  version = "0.0.1";

  src = fetchurl {
    url = "https://github.com/skolemlabs/${pname}/releases/download/${version}/${pname}-${version}.tbz";
    hash = "sha256-hmVAD9vgU1HLnB7d1TX17V+Alf5ZXmvQgd2nLHnLhDk=";
  };

  propagatedBuildInputs = [
    type_eq
  ];

  doCheck = true;

  checkInputs = [
    alcotest
  ];

  minimalOCamlVersion = "4.08.1";

  meta = {
    description = "Type identifiers, useful for runtime type-safe casting/coersions";
    homepage = "https://github.com/skolemlabs/type_id";
    changelog = "https://github.com/skolemlabs/type_id/blob/${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sixstring982 ];
  };
}
