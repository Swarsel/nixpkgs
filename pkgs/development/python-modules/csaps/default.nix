{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  poetry-core,
  pytestCheckHook,
  scipy,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "csaps";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "espdev";
    repo = "csaps";
    tag = "v${version}";
    hash = "sha256-1pNJaNExhcRWDjJenEKp1eJ4wZMFXxwWcmepEt6/p0s=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
    setuptools
  ];

  dependencies = [
    typing-extensions
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "csaps" ];

  meta = {
    description = "Cubic spline approximation (smoothing)";
    homepage = "https://github.com/espdev/csaps";
    changelog = "https://github.com/espdev/csaps/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
