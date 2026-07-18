{
  lib,
  buildPythonPackage,
  fetchPypi,
  netpbm,
  poppler-utils,
}:

buildPythonPackage rec {

  pname = "pnglatex";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CZUGDUkmttO0BzFYbGFSNMPkWzFC/BW4NmAeOwz4Y9M=";
  };

  propagatedBuildInputs = [
    poppler-utils
    netpbm
  ];

  # There are no tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Small program that converts LaTeX snippets to png";
    homepage = "https://github.com/MaT1g3R/pnglatex";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "pnglatex";
  };
}
