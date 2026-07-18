{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipykernel,
  isPy3k,
  markdown,
  matplotlib,
  mock,
  nbconvert,
  pkgs,
}:

buildPythonPackage rec {
  pname = "pweave";
  version = "0.30.3";

  src = fetchPypi {
    inherit version;
    sha256 = "5e5298d90e06414a01f48e0d6aa4c36a70c5f223d929f2a9c7e2d388451c7357";
    pname = "Pweave";
  };

  buildInputs = [
    mock
    pkgs.glibcLocales
  ];

  propagatedBuildInputs = [
    ipykernel
    matplotlib
    nbconvert
    markdown
  ];

  # fails due to trying to run CSS as test
  doCheck = false;
  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Scientific reports with embedded python computations with reST, LaTeX or markdown";
    homepage = "https://mpastell.com/pweave/";
    license = lib.licenses.bsd3;
  };
}
