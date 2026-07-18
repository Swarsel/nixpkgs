{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  aiobotocore,
  aiofiles,
  buildPythonPackage,
  # optional-dependencies
  # chalice
  chalice,
  # s3cse
  cryptography,
  # tests
  dill,
  moto,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "aioboto3";
  version = "15.5.0";

  src = fetchFromGitHub {
    owner = "terricain";
    repo = "aioboto3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yGKjcZlXs1f72OGX5rUWvfDKZAYU3ZV2RVQnd0InxBQ=";
  };

  nativeCheckInputs = [
    dill
    moto
    pytest-asyncio
    pytestCheckHook
  ]
  ++ moto.optional-dependencies.server
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiobotocore
    aiofiles
  ]
  ++ aiobotocore.optional-dependencies.boto3;

  disabledTests = [
    "test_patches"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Flaky: PermissionError: [Errno 13] Permission denied: '/tmp/somefile'
    "test_s3_copy"
    "test_s3_copy_multipart"
    "test_s3_download_file_404"
    "test_s3_upload_file"
  ]
  ++ [
    # DynamoDB tests fail with aiobotocore 3.x due to HTTP header issue with moto:
    # "Duplicate 'Server' header found" - same issue as aiobotocore disables
    "test_dynamo_resource_query"
    "test_dynamo_resource_put"
    "test_dynamo_resource_batch_write_flush_on_exit_context"
    "test_dynamo_resource_batch_write_flush_amount"
    "test_flush_doesnt_reset_item_buffer"
    "test_dynamo_resource_property"
    "test_dynamo_resource_waiter"
  ];

  optional-dependencies = {
    chalice = [ chalice ];
    s3cse = [ cryptography ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aioboto3" ];

  pythonRelaxDeps = [
    "aiobotocore"
  ];

  meta = {
    description = "Wrapper to use boto3 resources with the aiobotocore async backend";
    homepage = "https://github.com/terricain/aioboto3";
    changelog = "https://github.com/terricain/aioboto3/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
