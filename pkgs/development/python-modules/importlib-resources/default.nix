{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  importlib-metadata,
  # tests
  jaraco-collections,
  jaraco-test,
  pytestCheckHook,
  # Reverse dependency
  sage,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "importlib-resources";
  version = "7.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ByLUxiEkicUw8qFFo0wKejtHIbyWoV+tpZMOKgt2Bwg=";
    pname = "importlib_resources";
  };

  postPatch = ''
    sed -i '/coherent.licensed/d' pyproject.toml
  '';

  nativeCheckInputs = [
    pytestCheckHook
    jaraco-collections
    jaraco-test
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ importlib-metadata ];
  pyproject = true;
  pythonImportsCheck = [ "importlib_resources" ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Read resources from Python packages";
    homepage = "https://importlib-resources.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
