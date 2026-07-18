{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  factory-boy,
  # propagated
  inflection,
  # build-system
  poetry-core,
  # unpropagated
  pytest,
  # tests
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-factoryboy";
  version = "2.8.1";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-factoryboy";
    rev = version;
    sha256 = "sha256-9dMsUujMCk89Ze4H9VJRS+ihjk0PAxKb8xqlw0+ROEI=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    factory-boy
    inflection
    typing-extensions
  ];

  disabledTestPaths = [ "docs" ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_factoryboy" ];

  meta = {
    description = "Integration of factory_boy into the pytest runner";
    homepage = "https://pytest-factoryboy.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ winpat ];
  };
}
