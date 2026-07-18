{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  gremlinpython,
  hatchling,
  jsonpath-ng,
  moto,
  openpyxl,
  opensearch-py,
  pandas,
  pg8000,
  progressbar2,
  pyarrow,
  pymysql,
  pyodbc,
  pyparsing,
  pytestCheckHook,
  redshift-connector,
  requests-aws4auth,
  setuptools,
  sparqlwrapper,
}:

buildPythonPackage (finalAttrs: {
  pname = "awswrangler";
  version = "3.16.0";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-sdk-pandas";
    tag = finalAttrs.version;
    hash = "sha256-utxSM8S3uelwrLHrXx5NglOmqjS7YKnAPujNS7UhWf8=";
  };

  nativeCheckInputs = [
    moto
    pyparsing
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    boto3
    gremlinpython
    jsonpath-ng
    openpyxl
    opensearch-py
    pandas
    pg8000
    progressbar2
    pyarrow
    pymysql
    redshift-connector
    requests-aws4auth
    setuptools
  ];

  enabledTestPaths = [
    # Subset of tests that run in upstream CI (many others require credentials)
    # https://github.com/aws/aws-sdk-pandas/blob/20fec775515e9e256e8cee5aee12966516608840/.github/workflows/minimal-tests.yml#L36-L43
    "tests/unit/test_metadata.py"
    "tests/unit/test_session.py"
    "tests/unit/test_utils.py"
    "tests/unit/test_moto.py"
  ];

  optional-dependencies = {
    sparql = [ sparqlwrapper ];
    sqlserver = [ pyodbc ];
  };

  pyproject = true;
  pythonImportsCheck = [ "awswrangler" ];

  pythonRelaxDeps = [
    "packaging"
    "pyarrow"
  ];

  meta = {
    description = "Pandas on AWS";
    homepage = "https://github.com/aws/aws-sdk-pandas";
    changelog = "https://github.com/aws/aws-sdk-pandas/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mcwitt ];
  };
})
