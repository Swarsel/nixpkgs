{
  lib,
  azure-core,
  azure-storage-blob,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-storage-file-datalake";
  version = "12.23.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-lM4aIJ5ya846VCZoIpAfoZDSApyJtSvm9eeNfl+xCS8=";
    pname = "azure_storage_file_datalake";
  };

  # Tests are only available in mono repo
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    azure-storage-blob
    isodate
    typing-extensions
  ];

  optional-dependencies = {
    aio = [ azure-core ] ++ azure-core.optional-dependencies.aio;
  };

  pyproject = true;
  pythonImportsCheck = [ "azure.storage.filedatalake" ];

  meta = {
    description = "Microsoft Azure File DataLake Storage Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/storage/azure-storage-file-datalake";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-storage-file-datalake_${version}/sdk/storage/azure-storage-file-datalake/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
