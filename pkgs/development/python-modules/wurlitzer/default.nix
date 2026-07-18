{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "wurlitzer";
  version = "3.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-v7kUSrnwJIfYArn/idvT+jgtCPc+EtuK3EwvsAzTm9k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "wurlitzer" ];

  meta = {
    description = "Capture C-level output in context managers";
    homepage = "https://github.com/minrk/wurlitzer";
    changelog = "https://github.com/minrk/wurlitzer/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
