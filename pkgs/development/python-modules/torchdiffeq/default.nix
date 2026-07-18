{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  pytestCheckHook,
  scipy,
  # dependencies
  torch,
}:

buildPythonPackage rec {
  pname = "torchdiffeq";
  version = "0.2.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tQ03YNE/0TjczqxlH0uAOW9E/vzr0DegM/7P6qnMEuc=";
  };

  propagatedBuildInputs = [
    torch
    scipy
  ];

  # no tests in sdist, no tags on git
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "torchdiffeq" ];

  meta = {
    description = "Differentiable ODE solvers with full GPU support and O(1)-memory backpropagation";
    homepage = "https://github.com/rtqichen/torchdiffeq";
    license = lib.licenses.mit;
    teams = [ lib.teams.tts ];
  };
}
