{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "country-list";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bulv1ne";
    repo = "country_list";
    tag = "v${version}";
    hash = "sha256-jG2AC8c6mgWjHVBX7XW021PLPliLTwEBkN6+HSecfL4=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  enabledTestPaths = [
    "tests.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "country_list"
  ];

  meta = {
    description = "List of all countries with names and ISO 3166-1 codes in all languages";
    homepage = "https://github.com/bulv1ne/country_list";
    changelog = "https://github.com/bulv1ne/country_list/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ urbas ];
  };
}
