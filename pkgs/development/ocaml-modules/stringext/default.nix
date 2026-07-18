{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  ounit,
  qtest,
  # Optionally enable tests; test script use OCaml-4.01+ features
  doCheck ? lib.versionAtLeast ocaml.version "4.08",
}:

let
  version = "1.6.0";
in

buildDunePackage {
  inherit doCheck;
  pname = "stringext";
  version = version;

  src = fetchurl {
    url = "https://github.com/rgrinberg/stringext/releases/download/${version}/stringext-${version}.tbz";
    sha256 = "1sh6nafi3i9773j5mlwwz3kxfzdjzsfqj2qibxhigawy5vazahfv";
  };

  checkInputs = [
    ounit
    qtest
  ];

  duneVersion = "3";

  meta = {
    description = "Extra string functions for OCaml";
    homepage = "https://github.com/rgrinberg/stringext";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vbgl ];
  };
}
