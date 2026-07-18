{
  lib,
  fetchFromGitHub,
  behave,
  buildPythonPackage,
  pytest-mock,
  pytestCheckHook,
  ruamel-yaml,
  schema,
  setuptools,
}:

let
  version = "1.6.11";
in
buildPythonPackage rec {
  inherit version;
  pname = "sismic";

  src = fetchFromGitHub {
    owner = "AlexandreDecan";
    repo = "sismic";
    tag = version;
    hash = "sha256-MD8SN3xPY1YtonogVasZZoHLADm1GU5AARSFY7ZwVPU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    behave
    ruamel-yaml
    schema
  ];

  disabledTests = [
    # Time related tests, might lead to flaky tests on slow/busy machines
    "test_clock"
  ];

  enabledTestPaths = [ "tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "sismic" ];
  pythonRelaxDeps = [ "behave" ];

  meta = {
    description = "Sismic Interactive Statechart Model Interpreter and Checker";
    homepage = "https://github.com/AlexandreDecan/sismic";
    changelog = "https://github.com/AlexandreDecan/sismic/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
  };
}
