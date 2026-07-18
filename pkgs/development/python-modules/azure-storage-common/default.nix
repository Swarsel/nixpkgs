{
  lib,
  azure-common,
  azure-storage-nspkg,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  isPy3k,
  python-dateutil,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-storage-common";
  version = "2.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-zO3vXGcie8TWZw/9N87Bj7UpobfDpeU+QJbrDPI9xz8=";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    cryptography
    python-dateutil
    requests
  ]
  ++ lib.optional (!isPy3k) azure-storage-nspkg;

  pyproject = true;
  pythonImportsCheck = [ "azure.storage.common" ];

  meta = {
    description = "Client library for Microsoft Azure Storage services containing common code shared by blob, file and queue";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
  };
})
