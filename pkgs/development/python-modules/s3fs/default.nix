{
  lib,
  fetchFromGitHub,
  # dependencies
  aiobotocore,
  aiohttp,
  buildPythonPackage,
  # tests
  flask,
  flask-cors,
  fsspec,
  moto,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "s3fs";
  version = "2026.3.0";

  src = fetchFromGitHub {
    owner = "fsspec";
    repo = "s3fs";
    tag = version;
    hash = "sha256-CWZHu9PXW/YZosCVtnCJ4T6eQCmrdFcP0vkoGr+RAhM=";
  };

  nativeCheckInputs = [
    flask
    flask-cors
    moto
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiobotocore
    fsspec
    aiohttp
  ];

  disabledTests = [
    # require network access
    "test_async_close"
    "test_session_close"
  ];

  optional-dependencies = {
    awscli = aiobotocore.optional-dependencies.awscli;
    boto3 = aiobotocore.optional-dependencies.boto3;
  };

  pyproject = true;
  pythonImportsCheck = [ "s3fs" ];
  pythonRelaxDeps = [ "fsspec" ];

  meta = {
    description = "Pythonic file interface for S3";
    homepage = "https://github.com/fsspec/s3fs";
    changelog = "https://github.com/fsspec/s3fs/blob/${src.tag}/docs/source/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teh ];
  };
}
