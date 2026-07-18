{
  lib,
  fetchFromGitHub,
  attrs,
  boto3,
  buildPythonPackage,
  cryptography,
  mock,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  wrapt,
}:

buildPythonPackage (finalAttrs: {
  pname = "aws-encryption-sdk";
  version = "4.0.6";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "aws-encryption-sdk-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E3Kc0GREozdXzM5LvH1iapYl9yr17TyxauCooeJeLxo=";
  };

  nativeCheckInputs = [
    mock
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    boto3
    cryptography
    wrapt
  ];

  disabledTestPaths = [
    # Tests require networking
    "examples"
    "test/integration"
    # requires yet to be packaged aws-cryptographic-material-providers
    "test/mpl"
  ];

  disabledTests = [
    # pytest 8 compat issue
    "test_happy_version"
  ];

  enabledTestPaths = [ "test" ];
  pyproject = true;
  pythonImportsCheck = [ "aws_encryption_sdk" ];

  meta = {
    description = "Python implementation of the AWS Encryption SDK";
    homepage = "https://aws-encryption-sdk-python.readthedocs.io/";
    changelog = "https://github.com/aws/aws-encryption-sdk-python/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ anthonyroussel ];
  };
})
