{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyasyncore,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyasynchat";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "simonrob";
    repo = "pyasynchat";
    rev = "v${version}";
    hash = "sha256-KJmUou1llxUhDrMCOpJxqYNnPpJ0OoQv5VwYs/PJXbs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  preCheck = null;
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pyasyncore
  ];

  pyproject = true;

  pythonImportsCheck = [
    "asynchat"
  ];

  meta = {
    description = "Make asynchat available for Python 3.12 onwards";
    homepage = "https://github.com/simonrob/pyasynchat";
    license = lib.licenses.psfl;
    maintainers = [ ];
  };
}
