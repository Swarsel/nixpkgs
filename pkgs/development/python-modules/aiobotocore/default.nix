{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioitertools,
  anyio,
  awscli,
  boto3,
  botocore,
  buildPythonPackage,
  dill,
  httpx,
  jmespath,
  moto,
  multidict,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  time-machine,
  urllib3,
  werkzeug,
  wrapt,
}:

buildPythonPackage rec {
  pname = "aiobotocore";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "aiobotocore";
    tag = version;
    hash = "sha256-/Yf2rt/5FH1WiD2VV2hEksM1XleEl4YRBqGQI4GVa8Q=";
  };

  nativeCheckInputs = [
    anyio
    dill
    moto
    time-machine
    werkzeug
    pytestCheckHook
  ]
  ++ moto.optional-dependencies.server;

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    aioitertools
    botocore
    python-dateutil
    jmespath
    multidict
    urllib3
    wrapt
  ];

  disabledTestMarks = [
    # Exclude localonly tests (incompatible with moto mocks)
    "localonly"
  ];

  disabledTestPaths = [
    # Test requires network access
    "tests/test_version.py"
    "tests/test_basic_s3.py"
    "tests/test_batch.py"
    "tests/test_dynamodb.py"
    "tests/test_ec2.py"
    "tests/test_lambda.py"
    "tests/test_monitor.py"
    "tests/test_patches.py"
    "tests/test_sns.py"
    "tests/test_sqs.py"
    "tests/test_waiter.py"
  ];

  disabledTests = [
    # TypeError: sequence item 1: expected str instance, MagicMock found
    "test_signers_generate_db_auth_token"
  ];

  optional-dependencies = {
    awscli = [ awscli ];
    boto3 = [ boto3 ];
    httpx = [ httpx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiobotocore" ];
  # Relax version constraints: aiobotocore works with newer botocore versions
  # the pinning used to match some `extras_require` we're not using.
  pythonRelaxDeps = [ "botocore" ];

  meta = {
    description = "Python client for amazon services";
    homepage = "https://github.com/aio-libs/aiobotocore";
    changelog = "https://github.com/aio-libs/aiobotocore/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ teh ];
  };
}
