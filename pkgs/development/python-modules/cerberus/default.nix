{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cerberus";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "pyeve";
    repo = "cerberus";
    tag = finalAttrs.version;
    hash = "sha256-C7YZjqQtdkakqHXBU3cFUl/gCFvCl3saP14eqt2fdAM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
    setuptools
  ];

  disabledTestPaths = [
    # We don't care about benchmarks
    "cerberus/benchmarks/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cerberus" ];

  meta = {
    description = "Schema and data validation tool for Python dictionaries";
    homepage = "http://python-cerberus.org/";
    changelog = "https://github.com/pyeve/cerberus/blob/${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
