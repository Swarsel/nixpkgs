{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-fixture-classes";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "zmievsa";
    repo = "pytest-fixture-classes";
    tag = finalAttrs.version;
    hash = "sha256-we4Eax6wHlsbDoCzSUcbfwX+o2h3xCTaQZ3f5wStvZM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pytest_fixture_classes"
  ];

  meta = {
    description = "Fixtures as classes that work well with dependency injection, autocompletetion, type checkers, and language servers";
    homepage = "https://github.com/zmievsa/pytest-fixture-classes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ taranarmo ];
  };
})
