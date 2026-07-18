{
  lib,
  fetchFromGitHub,
  awscrt,
  buildPythonPackage,
  cacert,
  # dependencies
  jmespath,
  # tests
  jsonschema,
  pytestCheckHook,
  python-dateutil,
  # build-system
  setuptools,
  urllib3,
}:

buildPythonPackage rec {
  pname = "botocore";
  version = "1.42.31"; # N.B: if you change this, change boto3 and awscli to a matching version

  src = fetchFromGitHub {
    owner = "boto";
    repo = "botocore";
    tag = version;
    hash = "sha256-avuv1uXKMeSr3SL+BI9XW8tDCQM/dlXFn590di3S03k=";
  };

  postPatch = ''
    ln -sf ${cacert}/etc/ssl/certs/ca-no-trust-rules-bundle.crt botocore/cacert.pem
  '';

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    jmespath
    python-dateutil
    urllib3
  ];

  disabledTestPaths = [
    # Integration tests require networking
    "tests/integration"

    # Disable slow tests (only run unit tests)
    "tests/functional"
  ];

  optional-dependencies = {
    crt = [ awscrt ];
  };

  pyproject = true;
  pythonImportsCheck = [ "botocore" ];

  meta = {
    description = "Low-level interface to a growing number of Amazon Web Services";
    homepage = "https://github.com/boto/botocore";
    changelog = "https://github.com/boto/botocore/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anthonyroussel ];
  };
}
