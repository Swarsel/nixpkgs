{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  hypothesis,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "yamlloader";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "Phynix";
    repo = "yamlloader";
    tag = version;
    hash = "sha256-BByyKCCRZZYloxKKZVhSyH82I4hZNxCRqUddinRzYpE=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ pyyaml ];

  disabledTestPaths = [
    # TypeError: cannot pickle '_thread.RLock' object
    # https://github.com/Phynix/yamlloader/issues/64
    "tests/test_ordereddict.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "yaml"
    "yamlloader"
  ];

  meta = {
    description = "Case-insensitive list for Python";
    homepage = "https://github.com/Phynix/yamlloader";
    changelog = "https://github.com/Phynix/yamlloader/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
}
