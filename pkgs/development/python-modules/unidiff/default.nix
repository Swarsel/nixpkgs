{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "unidiff";
  version = "0.7.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "2e5f0162052248946b9f0970a40e9e124236bf86c82b70821143a6fc1dea2574";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "unidiff" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Unified diff python parsing/metadata extraction library";
    homepage = "https://github.com/matiasb/python-unidiff";
    changelog = "https://github.com/matiasb/python-unidiff/raw/v${finalAttrs.version}/HISTORY";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pbsds ];
    mainProgram = "unidiff";
  };
})
