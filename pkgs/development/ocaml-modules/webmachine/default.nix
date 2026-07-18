{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cohttp,
  dispatch,
  ounit,
  ptime,
}:

buildDunePackage rec {
  pname = "webmachine";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "inhabitedtype";
    repo = "ocaml-webmachine";
    rev = version;
    sha256 = "03ynb1l2jjqba88m9r8m5hwlm8izpfp617r4vcab5kmdim1l2ffx";
  };

  propagatedBuildInputs = [
    cohttp
    dispatch
    ptime
  ];

  doCheck = true;
  checkInputs = [ ounit ];
  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "REST toolkit for OCaml";
    homepage = "https://github.com/inhabitedtype/ocaml-webmachine";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };

}
