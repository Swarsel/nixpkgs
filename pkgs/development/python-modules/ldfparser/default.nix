{
  lib,
  fetchFromGitHub,
  bitstruct,
  buildPythonPackage,
  jinja2,
  jsonschema,
  lark,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ldfparser";
  version = "0.26.0";

  src = fetchFromGitHub {
    owner = "c4deszes";
    repo = "ldfparser";
    tag = "v${version}";
    hash = "sha256-SVl/O0/2k1Y4lta+3BFkddyBZfYO2vqh4Xx1ZXNwXN4=";
  };

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bitstruct
    jinja2
    lark
  ];

  disabledTestPaths = [
    # We don't care about benchmarks
    "tests/test_performance.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ldfparser" ];

  meta = {
    description = "LIN Description File parser written in Python";
    homepage = "https://github.com/c4deszes/ldfparser";
    changelog = "https://github.com/c4deszes/ldfparser/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ldfparser";
  };
}
