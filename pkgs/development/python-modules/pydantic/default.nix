{
  lib,
  fetchFromGitHub,
  # dependencies
  annotated-types,
  buildPythonPackage,
  # tests
  cloudpickle,
  dirty-equals,
  email-validator,
  hatch-fancy-pypi-readme,
  # build-system
  hatchling,
  hypothesis,
  inline-snapshot,
  jsonschema,
  pydantic-core,
  pytest-mock,
  pytest-run-parallel,
  pytest-timeout,
  pytestCheckHook,
  python,
  typing-extensions,
  typing-inspection,
}:

buildPythonPackage rec {
  pname = "pydantic";
  version = "2.13.4";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "v${version}";
    hash = "sha256-G4Xo6BF6tOn4g/qG3RNDP3/+lYnCOuw3AB1OrVOGcSA=";
  };

  postPatch = ''
    sed -i "/--benchmark/d" pyproject.toml
  '';

  nativeCheckInputs = [
    cloudpickle
    dirty-equals
    hypothesis
    (inline-snapshot.overridePythonAttrs { doCheck = false; })
    jsonschema
    pytest-mock
    pytest-run-parallel
    pytest-timeout
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    hatch-fancy-pypi-readme
    hatchling
  ];

  dependencies = [
    annotated-types
    pydantic-core
    typing-extensions
    typing-inspection
  ];

  disabledTestPaths = [
    "tests/benchmarks"
    "tests/pydantic_core/benchmarks"

    # avoid cyclic dependency
    "tests/test_docs.py"
  ];

  optional-dependencies = {
    email = [ email-validator ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pydantic" ];

  meta = {
    description = "Data validation and settings management using Python type hinting";
    homepage = "https://github.com/pydantic/pydantic";
    changelog = "https://github.com/pydantic/pydantic/blob/${src.tag}/HISTORY.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wd15 ];
  };
}
