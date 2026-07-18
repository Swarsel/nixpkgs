{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  packaging,
  pygls,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-lsp";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zZlQ/sKZHmU2RDDdQZ2u7fVGkoeI9FfhEG1bdRrqC+g=";
    pname = "pytest_lsp";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    pygls
    pytest-asyncio
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_lsp" ];

  meta = {
    description = "Pytest plugin for writing end-to-end tests for language servers";
    homepage = "https://github.com/swyddfa/lsp-devtools";
    changelog = "https://github.com/swyddfa/lsp-devtools/blob/develop/lib/pytest-lsp/CHANGES.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      clemjvdm
      fliegendewurst
    ];
  };
}
