{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-unordered";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "utapyngo";
    repo = "pytest-unordered";
    tag = "v${version}";
    hash = "sha256-JmP2zStxIt+u7sgfRKlnBwM5q5R0GfXtiE7ZgHKtg94=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_unordered" ];

  meta = {
    description = "Test equality of unordered collections in pytest";
    homepage = "https://github.com/utapyngo/pytest-unordered";
    changelog = "https://github.com/utapyngo/pytest-unordered/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}
