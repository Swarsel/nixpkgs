{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # dependencies
  typing-extensions,
  # tests
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "asserts";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "srittau";
    repo = "python-asserts";
    tag = "v${version}";
    hash = "sha256-nSL28LaKWVkzOmyI1TpCXJxyKdqpvK/YHRLUJ77sRA8=";
  };

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "asserts"
  ];

  meta = {
    description = "Stand-alone Assertions for Python";
    homepage = "https://github.com/srittau/python-asserts";
    changelog = "https://github.com/srittau/python-asserts/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
