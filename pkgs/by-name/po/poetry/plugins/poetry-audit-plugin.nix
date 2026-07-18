{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry,
  poetry-core,
  pytestCheckHook,
  safety,
}:

buildPythonPackage rec {
  pname = "poetry-audit-plugin";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "opeco17";
    repo = "poetry-audit-plugin";
    tag = version;
    hash = "sha256-aAQzgxzBJa/pK+hQj0tN4Zg1MG/sT0rbaMNMIxnhxdU=";
  };

  buildInputs = [
    poetry
  ];

  # requires networking
  doCheck = false;

  nativeCheckInputs = [
    poetry # for the executable
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    safety
  ];

  pyproject = true;
  pythonImportsCheck = [ "poetry_audit_plugin" ];

  meta = {
    description = "Poetry plugin for checking security vulnerabilities in dependencies";
    homepage = "https://github.com/opeco17/poetry-audit-plugin";
    changelog = "https://github.com/opeco17/poetry-audit-plugin/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
