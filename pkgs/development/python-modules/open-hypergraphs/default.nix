{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  hypothesis,
  numpy,
  pytestCheckHook,
  scipy,
}:

buildPythonPackage rec {
  pname = "open-hypergraphs";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "statusfailed";
    repo = "open-hypergraphs";
    tag = "pypi-${version}";
    hash = "sha256-sBF/+VENDajLN72UJ6iHekmk11pOqfxeKs8Kqszy6mQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "open_hypergraphs"
  ];

  pythonRelaxDeps = [
    "numpy"
    "scipy"
  ];

  meta = {
    description = "Implementation of open hypergraphs for string diagrams";
    homepage = "https://github.com/statusfailed/open-hypergraphs";
    changelog = "https://github.com/statusfailed/open-hypergraphs/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
