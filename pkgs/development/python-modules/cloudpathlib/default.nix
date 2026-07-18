{
  lib,
  fetchFromGitHub,
  # tests
  azure-identity,
  # optional-dependencies
  azure-storage-blob,
  azure-storage-file-datalake,
  boto3,
  buildPythonPackage,
  # build-system
  flit-core,
  google-cloud-storage,
  psutil,
  pydantic,
  pytest-cases,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  python-dotenv,
  shortuuid,
  tenacity,
}:

buildPythonPackage rec {
  pname = "cloudpathlib";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "drivendataorg";
    repo = "cloudpathlib";
    tag = "v${version}";
    hash = "sha256-MpCgK1JnQ/Etp0EyH5z6iknrQeJ4Wn6rwBw2EjgVAic=";
  };

  postPatch =
    # missing pytest-reportlog test dependency
    ''
      substituteInPlace pyproject.toml \
        --replace-fail "--report-log reportlog.jsonl" ""
    '';

  nativeCheckInputs = [
    azure-identity
    psutil
    pydantic
    pytestCheckHook
    pytest-cases
    pytest-cov-stub
    pytest-xdist
    python-dotenv
    shortuuid
    tenacity
  ]
  ++ optional-dependencies.all;

  __darwinAllowLocalNetworking = true;
  build-system = [ flit-core ];

  optional-dependencies = {
    all = optional-dependencies.azure ++ optional-dependencies.gs ++ optional-dependencies.s3;

    azure = [
      azure-storage-blob
      azure-storage-file-datalake
    ];

    gs = [ google-cloud-storage ];
    s3 = [ boto3 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cloudpathlib" ];

  meta = {
    description = "Python pathlib-style classes for cloud storage services such as Amazon S3, Azure Blob Storage, and Google Cloud Storage";
    homepage = "https://github.com/drivendataorg/cloudpathlib";
    changelog = "https://github.com/drivendataorg/cloudpathlib/blob/${src.tag}/HISTORY.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
