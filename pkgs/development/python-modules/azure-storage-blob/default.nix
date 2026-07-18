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
  pname = "azure-storage-blob";
  version = "12.28.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-59mOoQgljSmqDvv9WRsuIHX6FyKi+uhpnws8neEe/0E=";
    pname = "azure_storage_blob";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    cryptography
    isodate
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Client library for Microsoft Azure Storage services containing the blob service APIs";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-storage-blob_${version}/sdk/storage/azure-storage-blob/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      cmcdragonkai
      maxwilson
    ];
  };
}
