{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pillow,
}:
let
  version = "0.2.1";
in
buildPythonPackage {
  inherit version;
  pname = "pyphotonfile";

  src = fetchFromGitHub {
    owner = "cab404";
    repo = "pyphotonfile";
    rev = "b7ee92a0071007bb1d6a5984262651beec26543d";
    sha256 = "sha256-iB5ky4fPX8ZnvXlDpggqS/345k2x/mPC4cIgb9M0f/c=";
  };

  propagatedBuildInputs = [
    pillow
    numpy
  ];

  format = "setuptools";

  meta = {
    description = "Library for reading and writing files for the Anycubic Photon 3D-Printer";
    homepage = "https://github.com/cab404/pyphotonfile";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.cab404 ];
  };
}
