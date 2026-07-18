{
  lib,
  buildPythonPackage,
  fetchPypi,

  # dependencies
  numpy,
  torch,
}:

buildPythonPackage rec {
  pname = "resize-right";
  version = "0.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fcNbcs5AErd/fMkEmDUWN5OrmKWKuIk2EPsRn+Wa9SA=";
  };

  propagatedBuildInputs = [
    numpy
    torch
  ];

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "resize_right" ];

  meta = {
    description = "Correct way to resize images or tensors. For Numpy or Pytorch (differentiable";
    homepage = "https://github.com/assafshocher/ResizeRight";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
