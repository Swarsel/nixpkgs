{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "poetry-plugin-migrate";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "zyf722";
    repo = "poetry-plugin-migrate";
    tag = version;
    hash = "sha256-78H4/vHp8W7h6v6OWUdx9pX4142YiNGUFZXHoxxXw1M=";
  };

  buildInputs = [
    poetry
  ];

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "poetry_plugin_migrate" ];

  meta = {
    description = "Poetry plugin to migrate pyproject.toml from Poetry v1 to v2 (PEP-621 compliant)";
    homepage = "https://github.com/zyf722/poetry-plugin-migrate";
    changelog = "https://github.com/zyf722/poetry-plugin-migrate/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zevisert ];
  };
}
