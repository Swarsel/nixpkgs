{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  httpretty,
  keyring,
  lz4,
  orjson,
  pytestCheckHook,
  python-dateutil,
  pytz,
  requests,
  requests-gssapi,
  requests-kerberos,
  setuptools,
  sqlalchemy,
  testcontainers,
  tzlocal,
  zstandard,
}:

buildPythonPackage rec {
  pname = "trino-python-client";
  version = "0.338.0";

  src = fetchFromGitHub {
    owner = "trinodb";
    repo = "trino-python-client";
    tag = version;
    hash = "sha256-kWbqzdeOkzjhcaQOS4bCUnXFILpurtVE3N3KLoqSeds=";
  };

  nativeCheckInputs = [
    boto3
    httpretty
    pytestCheckHook
    testcontainers
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    lz4
    orjson
    python-dateutil
    pytz
    requests
    tzlocal
    zstandard
  ];

  disabledTestMarks = [ "auth" ];

  disabledTestPaths = [
    # Tests require a running trino instance
    "tests/integration/test_types_integration.py"
    "tests/integration/test_dbapi_integration.py"
    "tests/integration/test_sqlalchemy_integration.py"
  ];

  disabledTests = [
    # Tests require a running trino instance
    "test_oauth2"
    "test_token_retrieved_once_when_authentication_instance_is_shared"
    "test_multithreaded_oauth2_authentication_flow"
  ];

  optional-dependencies = lib.fix (self: {
    all = self.kerberos ++ self.sqlalchemy;
    external-authentication-token-cache = [ keyring ];
    gsaapi = [ requests-gssapi ];
    kerberos = [ requests-kerberos ];
    sqlalchemy = [ sqlalchemy ];
  });

  pyproject = true;
  pythonImportsCheck = [ "trino" ];

  meta = {
    description = "Client for the Trino distributed SQL Engine";
    homepage = "https://github.com/trinodb/trino-python-client";
    changelog = "https://github.com/trinodb/trino-python-client/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cpcloud
      flokli
    ];
  };
}
