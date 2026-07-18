{
  lib,
  attrs,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytest-cov-stub,
  pytest-xdist,
  pytest7CheckHook,
  ruamel-yaml,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "demes";
  version = "0.2.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nmE7ZbR126J3vKdR3h83qJ/V602Fa6J3M6IJnIqCNhc=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    ruamel-yaml
    attrs
  ];

  nativeCheckInputs = [
    pytest7CheckHook
    pytest-cov-stub
    pytest-xdist
    numpy
  ];

  disabledTestPaths = [ "tests/test_spec.py" ];
  pyproject = true;
  pythonImportsCheck = [ "demes" ];

  meta = {
    description = "Tools for describing and manipulating demographic models";
    homepage = "https://github.com/popsim-consortium/demes-python";
    license = lib.licenses.isc;
    maintainers = [ ];
    mainProgram = "demes";
  };
}
