{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  # dependencies
  flask,
  jsonschema,
  mistune,
  packaging,
  # tests
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  six,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "flasgger";
  version = "0.9.7.1";

  src = fetchFromGitHub {
    owner = "flasgger";
    repo = "flasgger";
    rev = "v${version}";
    hash = "sha256-ULEf9DJiz/S2wKlb/vjGto8VCI0QDcm0pkU5rlOwtiE=";
  };

  patches = [
    # https://github.com/flasgger/flasgger/pull/633
    (fetchpatch {
      hash = "sha256-DHaaY9W+cta3M2VA8S+ZQWacmgSpeyP03SKTiIlfBRM=";
      name = "fix-tests-with-click-8.2.patch";
      url = "https://github.com/flasgger/flasgger/commit/08591b60e988c0002fcf1b1e9f98b78e041d2732.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    flask
    jsonschema
    mistune
    packaging
    pyyaml
    six
    werkzeug
  ];

  disabledTestPaths = [
    # missing flex dependency
    "tests/test_examples.py"
  ];

  enabledTestPaths = [
    "tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flasgger" ];

  meta = {
    description = "Easy OpenAPI specs and Swagger UI for your Flask API";
    homepage = "https://github.com/flasgger/flasgger/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
