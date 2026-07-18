{
  lib,
  fetchFromGitHub,
  # tests
  argcomplete,
  buildPythonPackage,
  # build-system
  hatchling,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "traitlets";
  version = "5.14.3";

  src = fetchFromGitHub {
    owner = "ipython";
    repo = "traitlets";
    tag = "v${version}";
    hash = "sha256-lWtgzXW1ffzl1jkFaq99X0dU8agulUMHaghsYKX+8Dk=";
  };

  nativeCheckInputs = [
    argcomplete
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  disabledTestPaths = [
    # requires mypy-testing
    "tests/test_typing.py"
  ];

  disabledTests = [
    # https://github.com/ipython/traitlets/issues/902
    "test_complete_custom_completers"
    # https://github.com/ipython/traitlets/issues/925
    "test_complete_simple_app"
    "test_complete_subcommands_subapp1"
  ];

  pyproject = true;

  meta = {
    description = "Traitlets Python config system";
    homepage = "https://github.com/ipython/traitlets";
    changelog = "https://github.com/ipython/traitlets/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
  };
}
