{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ounit,
}:

buildDunePackage {
  pname = "mlbdd";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "arlencox";
    repo = "mlbdd";
    rev = "v0.7.3";
    hash = "sha256-TUdgx+B5341VJsnP7iTHID7hNC+5G/I2xNM5F3mdb/A=";
  };

  doCheck = true;
  checkInputs = [ ounit ];
  minimalOCamlVersion = "4.04";

  meta = {
    description = "Not-quite-so-simple Binary Decision Diagrams implementation for OCaml";
    homepage = "https://github.com/arlencox/mlbdd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ katrinafyi ];
  };
}
