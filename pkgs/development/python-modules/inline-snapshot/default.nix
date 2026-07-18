{
  lib,
  fetchFromGitHub,
  asttokens,
  black,
  buildPythonPackage,
  dirty-equals,
  executing,
  hatchling,
  hypothesis,
  isort,
  pydantic,
  pytest,
  pytest-freezer,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  rich,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "inline-snapshot";
  version = "0.32.5";

  src = fetchFromGitHub {
    owner = "15r10nk";
    repo = "inline-snapshot";
    tag = version;
    hash = "sha256-xnooMIm0UiNOWrZ4JZwbpFzliGsTF7b1DAXi1fxMb30=";
  };

  buildInputs = [
    pytest
  ];

  nativeCheckInputs = [
    hypothesis
    isort
    pydantic
    pytest-freezer
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  dependencies = [
    asttokens
    executing
    rich
    typing-extensions
  ];

  disabledTestPaths = [
    # Tests don't play nice with pytest-xdist
    "tests/test_typing.py"
  ];

  optional-dependencies = {
    black = [ black ];
    dirty-equals = [ dirty-equals ];
  };

  pyproject = true;
  pythonImportsCheck = [ "inline_snapshot" ];

  meta = {
    description = "Create and update inline snapshots in Python tests";
    homepage = "https://github.com/15r10nk/inline-snapshot/";
    changelog = "https://github.com/15r10nk/inline-snapshot/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
