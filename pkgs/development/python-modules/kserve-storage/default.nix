{
  lib,
  # dependencies
  azure-identity,
  azure-storage-blob,
  azure-storage-file-share,
  boto3,
  buildPythonPackage,
  fetchPypi,
  google-cloud-storage,
  huggingface-hub,
  # tests
  pytestCheckHook,
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "kserve-storage";
  version = "0.16.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-xgLnWegsPF18RLxwxt0dfnrZwsX7AK3b8AdT594Bac4=";
    pname = "kserve_storage";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    azure-identity
    azure-storage-blob
    azure-storage-file-share
    boto3
    google-cloud-storage
    huggingface-hub
    requests
  ];

  disabledTests = [
    # RuntimeError: Failed to fetch model. No model found in file:///tmp.
    "test_local_path_with_out_dir_exist"
  ];

  pyproject = true;
  pythonImportsCheck = [ "kserve_storage" ];

  pythonRelaxDeps = [
    "google-cloud-storage"
  ];

  meta = {
    description = "KServe Storage Handler. This module is responsible to download the models from the provided source";
    homepage = "https://pypi.org/project/kserve-storage";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
