{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "poetry-plugin-up";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "MousaZeidBaker";
    repo = "poetry-plugin-up";
    tag = "v${version}";
    hash = "sha256-gVhx8Vhk+yT/QjcEme8w0F+6BBpnEZOqzCkUJgM9eck=";
  };

  buildInputs = [
    poetry
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    writableTmpDirAsHomeHook
  ];

  build-system = [
    poetry-core
  ];

  disabledTests = [
    # https://github.com/MousaZeidBaker/poetry-plugin-up/issues/78
    "test_command_preserve_wildcard_project"
    "test_command_with_latest_project"
  ];

  pyproject = true;

  meta = {
    description = "Poetry plugin to simplify package updates";
    homepage = "https://github.com/MousaZeidBaker/poetry-plugin-up";
    changelog = "https://github.com/MousaZeidBaker/poetry-plugin-up/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.k900 ];
  };
}
