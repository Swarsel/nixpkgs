{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  filelock,
  mypy,
  pytest,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-mypy";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-P1/K/3XIDczGtoz17MKOG75x6VMJRp63oov0CM5VwHQ=";
    pname = "pytest_mypy";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  buildInputs = [ pytest ];

  propagatedBuildInputs = [
    attrs
    mypy
    filelock
  ];

  # does not contain tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pytest_mypy" ];

  meta = {
    description = "Mypy static type checker plugin for Pytest";
    homepage = "https://github.com/dbader/pytest-mypy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
