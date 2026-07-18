{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  json-flatten,
  packageurl-python,
  pytestCheckHook,
  semver,
  setuptools,
  toml,
}:

buildPythonPackage rec {
  pname = "custom-json-diff";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "appthreat";
    repo = "custom-json-diff";
    tag = "v${version}";
    hash = "sha256-09kSj4fJHQHyzsCk0bSVlwAgkyzWOSjRKxU1rcMXacQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    jinja2
    json-flatten
    packageurl-python
    semver
    toml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "custom_json_diff"
  ];

  meta = {
    description = "Utility to compare json documents containing dynamically-generated fields";
    homepage = "https://github.com/appthreat/custom-json-diff";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
