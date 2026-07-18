{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build inputs
  jsonref,
  jsonschema,
  mock,
  msgpack,
  # check inputs
  pytestCheckHook,
  python-dateutil,
  pytz,
  pyyaml,
  requests,
  setuptools,
  simplejson,
  six,
  swagger-spec-validator,
}:

buildPythonPackage rec {
  pname = "bravado-core";
  version = "6.4.1";

  src = fetchFromGitHub {
    owner = "Yelp";
    repo = "bravado-core";
    rev = "v${version}";
    hash = "sha256-P6R1Pmhddyy1iwQuem8YVDFFrQ4qxHzASZQbqpMZXeI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    jsonref
    jsonschema # jsonschema[format-nongpl]
    python-dateutil
    pyyaml
    requests
    simplejson
    six
    swagger-spec-validator
    pytz
    msgpack
  ]
  ++ jsonschema.optional-dependencies.format-nongpl;

  disabledTestPaths = [
    # skip benchmarks
    "tests/profiling"
    # take too long to run
    "tests/spec/Spec"
  ];

  pyproject = true;
  pythonImportsCheck = [ "bravado_core" ];

  meta = {
    description = "Library for adding Swagger support to clients and servers";
    homepage = "https://github.com/Yelp/bravado-core";
    changelog = "https://github.com/Yelp/bravado-core/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      vanschelven
      nickcao
    ];
  };
}
