{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build inputs
  inflect,
  joblib,
  num2words,
  numpy,
  scikit-learn,
  scipy,
  setuptools,
  stemming,
  wikipedia,
}:
let
  pname = "quantulum3";
  version = "0.10.0";
in
buildPythonPackage {
  inherit version pname;

  # Pypi source package doesn't contain tests
  src = fetchFromGitHub {
    owner = "nielstron";
    repo = "quantulum3";
    rev = "9dafd76d3586aa5ea1b96164d86c73037e827294";
    hash = "sha256-fHztPeTbMp1aYsj+STYWzHgwdY0Q9078qXpXxtA8pPs=";
  };

  propagatedBuildInputs = [
    inflect
    num2words
    numpy
    scipy
    scikit-learn
    joblib
    wikipedia
    stemming
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "quantulum3" ];

  meta = {
    description = "Library for unit extraction - fork of quantulum for python3";
    homepage = "https://github.com/nielstron/quantulum3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "quantulum3-training";
  };
}
