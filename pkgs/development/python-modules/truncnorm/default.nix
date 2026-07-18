{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "truncnorm";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "jluttine";
    repo = "truncnorm";
    tag = version;
    hash = "sha256-F+RBXN/pjxmHf26/Vxptz1NbF58eqU018l3zmepSoJk=";
  };

  # No checks
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "truncnorm" ];

  meta = {
    description = "Moments for doubly truncated multivariate normal distributions";
    homepage = "https://pypi.org/project/truncnorm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
