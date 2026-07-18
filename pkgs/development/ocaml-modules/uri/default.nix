{
  lib,
  fetchurl,
  angstrom,
  buildDunePackage,
  ounit,
  stringext,
}:

buildDunePackage rec {
  pname = "uri";
  version = "4.4.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-${pname}/releases/download/v${version}/${pname}-${version}.tbz";
    sha256 = "cdabaf6ef5cd2161e59cc7b74c6e4a68ecb80a9f4e96002e338e1b6bf17adec4";
  };

  propagatedBuildInputs = [
    angstrom
    stringext
  ];

  doCheck = true;
  checkInputs = [ ounit ];
  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "RFC3986 URI parsing library for OCaml";
    homepage = "https://github.com/mirage/ocaml-uri";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
