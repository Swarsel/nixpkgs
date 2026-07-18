{
  lib,
  azure-core,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-storage-file-share";
  version = "12.24.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-kPmwI053H9oIv1YQPEOk9KwIv3kzTZ2se7G283uq3SU=";
    pname = "azure_storage_file_share";
  };

  # Tests require checkout from monorepo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    cryptography
    isodate
    typing-extensions
  ];

  optional-dependencies = {
    aio = [ azure-core ] ++ azure-core.optional-dependencies.aio;
  };

  pyproject = true;

  pythonImportsCheck = [
    "azure.core"
    "azure.storage"
  ];

  meta = {
    description = "Microsoft Azure File Share Storage Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/storage/azure-storage-file-share";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-storage-file-share_${version}/sdk/storage/azure-storage-file-share/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
  };
}
