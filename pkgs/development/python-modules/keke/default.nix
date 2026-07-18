{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  wheel,
}:

buildPythonPackage rec {
  pname = "keke";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-H0U6DgZOHKtkPnF/xSNqBGPnD4BViP0JBKpehKKTTzs=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  installCheckPhase = ''
    python -m keke.tests
  '';

  build-system = [
    setuptools
    wheel
  ];

  pyproject = true;

  pythonImportsCheck = [
    "keke"
  ];

  meta = {
    description = "Easy profiling in chrome trace format";
    homepage = "https://pypi.org/project/keke/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthewcroughan ];
  };
}
