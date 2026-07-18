{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  filelock,
  hatchling,
  polars,
  pytest,
  pytest-xdist,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-shared-session-scope";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "StefanBRas";
    repo = "pytest-shared-session-scope";
    tag = "v${version}";
    hash = "sha256-IPTktwOJhzoC7/gPgMVwbLCkRuhbPf90m23yznqHha4=";
  };

  nativeCheckInputs = [
    polars
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    filelock
    pytest
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_shared_session_scope" ];

  meta = {
    description = "Pytest session-scoped fixture that works with xdist";
    homepage = "https://pypi.org/project/pytest-shared-session-scope/";
    changelog = "https://github.com/StefanBRas/pytest-shared-session-scope/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
