{
  lib,
  azure-common,
  azure-storage-common,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  setuptools,
  futures ? null,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-storage-file";
  version = "2.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NVm5x6sTRQxm6oM+uCwoIzvuJPG9jKGap9J/jCPVvFM=";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-storage-common
  ]
  ++ lib.optional (!isPy3k) futures;

  pyproject = true;
  pythonImportsCheck = [ "azure.storage.file" ];

  meta = {
    description = "Client library for Microsoft Azure Storage services containing the file service APIs";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
  };
})
