{
  lib,
  fetchFromGitHub,
  # dependencies
  botocore,
  buildPythonPackage,
  jmespath,
  # tests
  pytest-xdist,
  pytestCheckHook,
  s3transfer,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  inherit (botocore) version; # N.B: botocore, boto3, awscli needs to be updated in lockstep, bump botocore version for updating these.
  pname = "boto3";

  src = fetchFromGitHub {
    owner = "boto";
    repo = "boto3";
    tag = finalAttrs.version;
    hash = "sha256-fzwVxbn4+5zkcAKQ9+bEbNSdwcPKZqsNIJZPqhV+n8w=";
  };

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    botocore
    jmespath
    s3transfer
  ];

  disabledTestPaths = [
    # Integration tests require networking
    "tests/integration"
  ];

  optional-dependencies = {
    crt = botocore.optional-dependencies.crt;
  };

  pyproject = true;
  pythonImportsCheck = [ "boto3" ];

  meta = {
    description = "AWS SDK for Python";

    longDescription = ''
      Boto3 is the Amazon Web Services (AWS) Software Development Kit (SDK) for
      Python, which allows Python developers to write software that makes use of
      services like Amazon S3 and Amazon EC2.
    '';

    homepage = "https://github.com/boto/boto3";
    changelog = "https://github.com/boto/boto3/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anthonyroussel ];
  };
})
