{
  lib,
  fetchFromGitHub,
  asttokens,
  buildPythonPackage,
  cython,
  executing,
  littleutils,
  pure-eval,
  pygments,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  typeguard,
  wheel,
}:

buildPythonPackage rec {
  pname = "stack-data";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "alexmojaki";
    repo = "stack_data";
    tag = "v${version}";
    hash = "sha256-dmBhfCg60KX3gWp3k1CGRxW14z3BLlair0PjLW9HFYo=";
  };

  nativeCheckInputs = [
    cython
    littleutils
    pygments
    pytestCheckHook
    typeguard
  ];

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [
    asttokens
    executing
    pure-eval
  ];

  disabledTests = [
    # AssertionError
    "test_example"
    "test_executing_style_defs"
    "test_pygments_example"
    "test_variables"
  ];

  pyproject = true;
  pythonImportsCheck = [ "stack_data" ];

  meta = {
    description = "Extract data from stack frames and tracebacks";
    homepage = "https://github.com/alexmojaki/stack_data/";
    changelog = "https://github.com/alexmojaki/stack_data/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
    mainProgram = "stack-data";
  };
}
