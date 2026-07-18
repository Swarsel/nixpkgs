{
  lib,
  fetchFromGitHub,
  awscli2,
  azure-common,
  azure-core,
  azure-storage-blob,
  backports-zstd,
  boto3,
  buildPythonPackage,
  google-cloud-storage,
  moto,
  numpy,
  paramiko,
  pyopenssl,
  pytest-cov-stub,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  setuptools-scm,
  wrapt,
}:

buildPythonPackage rec {
  pname = "smart-open";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "RaRe-Technologies";
    repo = "smart_open";
    tag = "v${version}";
    hash = "sha256-MKQvvz75PBUZwQ9e/vR+XGdaT+pD2agZtdHOV0Gw9Kk=";
  };

  nativeCheckInputs = [
    awscli2
    moto
    numpy
    pytest-cov-stub
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    pyopenssl
    responses
  ]
  ++ moto.optional-dependencies.server
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ wrapt ];

  disabledTests = [
    # https://github.com/RaRe-Technologies/smart_open/issues/784
    "test_https_seek_forward"
    "test_seek_from_current"
    "test_seek_from_end"
    "test_seek_from_start"
  ];

  enabledTestPaths = [ "tests" ];

  optional-dependencies = {
    azure = [
      azure-storage-blob
      azure-common
      azure-core
    ];

    gcs = [ google-cloud-storage ];
    http = [ requests ];
    s3 = [ boto3 ];
    ssh = [ paramiko ];
    webhdfs = [ requests ];
    zst = [ backports-zstd ];
  };

  pyproject = true;
  pythonImportsCheck = [ "smart_open" ];

  meta = {
    description = "Library for efficient streaming of very large file";
    homepage = "https://github.com/piskvorky/smart_open";
    changelog = "https://github.com/piskvorky/smart_open/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
