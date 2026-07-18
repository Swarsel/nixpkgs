{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pystache";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "PennyDreadfulMTG";
    repo = "pystache";
    tag = "v${version}";
    hash = "sha256-UVmDpg7wCPnY+1BZqujIYdgt/AT4gZ+RTYdD+ORQhzE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pystache" ];

  meta = {
    description = "Framework-agnostic, logic-free templating system inspired by ctemplate and et";
    homepage = "https://github.com/PennyDreadfulMTG/pystache";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nickcao ];
  };
}
