{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  pyvirtualdisplay,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-xvfb";
  version = "3.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-kFk2NEJ9l0snLoRXk+RTP1uCfJ2EwFGHkBNiRQQXXkQ=";
    pname = "pytest_xvfb";
  };

  buildInputs = [ pytest ];
  build-system = [ setuptools ];
  dependencies = [ pyvirtualdisplay ];
  pyproject = true;

  meta = {
    description = "Pytest plugin to run Xvfb for tests";
    homepage = "https://github.com/The-Compiler/pytest-xvfb";
    changelog = "https://github.com/The-Compiler/pytest-xvfb/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
