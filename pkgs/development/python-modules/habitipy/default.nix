{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  plumbum,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "habitipy";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "ASMfreaK";
    repo = "habitipy";
    tag = "v${version}";
    hash = "sha256-AEeTCrxLXkokRRnNUfW4y23Qdh8ek1F88GmCPLGb84A=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    responses
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools ];

  dependencies = [
    plumbum
    requests
    setuptools
  ];

  disabledTests = [
    # network access
    "test_content_cache"
    # hypothesis.errors.InvalidArgument: tests/test_cli.py::test_data is a function that returns a Hypothesis strategy, but pytest has collected it as a test function.
    "test_data"
  ];

  pyproject = true;
  pythonImportsCheck = [ "habitipy" ];

  meta = {
    description = "Tools and library for Habitica restful API";
    homepage = "https://github.com/ASMfreaK/habitipy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "habitipy";
  };
}
