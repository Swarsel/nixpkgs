{
  lib,
  fetchFromGitHub,
  astor,
  asttokens,
  asyncstdlib,
  buildPythonPackage,
  deal,
  dpcontracts,
  numpy,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "icontract";
  version = "2.7.3";

  src = fetchFromGitHub {
    owner = "Parquery";
    repo = "icontract";
    tag = "v${version}";
    hash = "sha256-UYBskomnu53A9VCY7y7zAOQm40Y+INOqPK6IqZsk6h0=";
  };

  nativeCheckInputs = [
    astor
    asyncstdlib
    deal
    dpcontracts
    numpy
    pytestCheckHook
  ];

  preCheck = ''
    # we don't want to use the precommit.py script to build the package.
    # For the tests to succeed, "ICONTRACT_SLOW" needs to be set.
    # see https://github.com/Parquery/icontract/blob/aaeb1b06780a34b05743377e4cb2458780e808d3/precommit.py#L57
    export ICONTRACT_SLOW=1
  '';

  build-system = [ setuptools ];

  dependencies = [
    asttokens
    typing-extensions
  ];

  disabledTestPaths = [
    # mypy decorator checks don't pass. For some reason mypy
    # doesn't check the python file provided in the test.
    "tests/test_mypy_decorators.py"
    # Those tests seems to simply re-run some typeguard tests
    "tests/test_typeguard.py"
  ];

  disabledTests = [
    # AssertionError
    "test_abstract_method_not_implemented"
  ];

  pyproject = true;

  pytestFlags = [
    # RuntimeWarning: coroutine '*' was never awaited
    "-Wignore::RuntimeWarning"
  ];

  pythonImportsCheck = [ "icontract" ];

  pythonRelaxDeps = [
    "asttokens"
  ];

  meta = {
    description = "Provide design-by-contract with informative violation messages";
    homepage = "https://github.com/Parquery/icontract";
    changelog = "https://github.com/Parquery/icontract/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gador
      thiagokokada
    ];
  };
}
