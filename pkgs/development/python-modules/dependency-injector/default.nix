{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  aiohttp,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  fastapi,
  flask,
  httpx,
  mypy-boto3-s3,
  numpy,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  scipy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "dependency-injector";
  version = "4.49.1";

  src = fetchFromGitHub {
    owner = "ets-labs";
    repo = "python-dependency-injector";
    tag = finalAttrs.version;
    hash = "sha256-ncxKYzkV10hA2D8U1/zvkYJ/VFhNUsvRaOBNjzhIdtA=";
  };

  nativeCheckInputs = [
    fastapi
    httpx
    mypy-boto3-s3
    numpy
    pytest-asyncio
    pytestCheckHook
    scipy
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
  ];

  disabledTestPaths = [
    # Exclude tests for EOL Python releases
    "tests/unit/ext/test_aiohttp_py35.py"
    "tests/unit/wiring/test_*_py36.py"
    "tests/unit/providers/configuration/test_from_pydantic_py36.py"
    "tests/unit/providers/configuration/test_pydantic_settings_in_init_py36.py"

    # Requires unpackaged fast-depends
    "tests/unit/wiring/test_fastdepends.py"
  ];

  optional-dependencies = {
    aiohttp = [ aiohttp ];
    flask = [ flask ];
    pydantic = [ pydantic ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dependency_injector" ];

  meta = {
    description = "Dependency injection microframework for Python";
    homepage = "https://github.com/ets-labs/python-dependency-injector";
    changelog = "https://github.com/ets-labs/python-dependency-injector/blob/${finalAttrs.src.tag}/docs/main/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ gerschtli ];
  };
})
