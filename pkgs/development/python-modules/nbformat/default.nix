{
  lib,
  buildPythonPackage,
  fastjsonschema,
  fetchPypi,
  hatch-nodejs-version,
  hatchling,
  jsonschema,
  jupyter-core,
  pep440,
  pytestCheckHook,
  pythonAtLeast,
  testpath,
  traitlets,
}:

buildPythonPackage rec {
  pname = "nbformat";
  version = "5.10.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MiFosU+Tel0RNimI7KwqSVLT2OOiy+sjGVhGMSJtWzo=";
  };

  nativeCheckInputs = [
    pep440
    pytestCheckHook
    testpath
  ];

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  build-system = [
    hatchling
    hatch-nodejs-version
  ];

  dependencies = [
    fastjsonschema
    jsonschema
    jupyter-core
    traitlets
  ];

  pyproject = true;
  pytestFlags = [ "-Wignore::pytest.PytestUnraisableExceptionWarning" ];
  pythonImportsCheck = [ "nbformat" ];

  meta = {
    description = "Jupyter Notebook format";
    homepage = "https://jupyter.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "jupyter-trust";
  };
}
