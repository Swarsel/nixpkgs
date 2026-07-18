{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nsw-fuel-api-client";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "nickw444";
    repo = "nsw-fuel-api-client";
    tag = version;
    hash = "sha256-3nkBDLmFOfYLvG5fi2subA9zxb51c7zWlhT4GaCQo9I=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
  ];

  pyproject = true;

  pytestFlags = [
    "nsw_fuel_tests/unit.py"
  ];

  pythonImportsCheck = [
    "nsw_fuel"
  ];

  meta = {
    description = "API Client for NSW Government Fuel Check application";
    homepage = "https://github.com/nickw444/nsw-fuel-api-client";
    changelog = "https://github.com/nickw444/nsw-fuel-api-client/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
