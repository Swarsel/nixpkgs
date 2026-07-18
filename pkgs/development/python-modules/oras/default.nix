{
  lib,
  fetchFromGitHub,
  boto3,
  buildPythonPackage,
  jsonschema,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "oras";
  version = "0.2.42";

  src = fetchFromGitHub {
    owner = "oras-project";
    repo = "oras-py";
    tag = finalAttrs.version;
    hash = "sha256-fuDvhz7dTsPM1AZkPUUgalXUnslAKqTXplslbOUjS/I=";
  };

  nativeCheckInputs = [
    boto3
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    jsonschema
    requests
  ];

  disabledTests = [
    # Test requires network access
    "test_get_many_tags"
    "test_ssl"
  ];

  pyproject = true;
  pythonImportsCheck = [ "oras" ];

  meta = {
    description = "ORAS Python SDK";
    homepage = "https://github.com/oras-project/oras-py";
    changelog = "https://github.com/oras-project/oras-py/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
