{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  black,
  # dependencies
  boto3,
  buildPythonPackage,
  importlib-metadata,
  jsonschema,
  mock,
  pandas,
  platformdirs,
  pydantic,
  pylint,
  pytest,
  # tests
  pytestCheckHook,
  pyyaml,
  rich,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "sagemaker-core";
  version = "1.0.78";

  src = fetchFromGitHub {
    owner = "aws";
    repo = "sagemaker-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pSxOMbw6ZUdlVTYoSW5ZwpTTh5VEJFf8U6sNq6kb5vM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    setuptools
  ];

  dependencies = [
    boto3
    importlib-metadata
    jsonschema
    mock
    platformdirs
    pydantic
    pyyaml
    rich
  ];

  disabledTestPaths = [
    # Tries to import deprecated `sklearn`
    "integ/test_codegen.py"

    # botocore.exceptions.NoRegionError: You must specify a region
    "tst/generated/test_logs.py"
  ];

  optional-dependencies = {
    codegen = [
      black
      pandas
      pylint
      pytest
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "sagemaker_core"
  ];

  pythonRelaxDeps = [
    "boto3"
    "importlib-metadata"
    "mock"
    "rich"
  ];

  meta = {
    description = "Python object-oriented interface for interacting with Amazon SageMaker resources";
    homepage = "https://github.com/aws/sagemaker-core";
    changelog = "https://github.com/aws/sagemaker-core/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
