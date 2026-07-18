{
  lib,
  azure-nspkg,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-storage-nspkg";
  version = "3.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-bzu+hlLV9UJ2fYQz5/lrjff1GHdAVax8ku18qF9lOBE=";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ azure-nspkg ];
  pyproject = true;

  meta = {
    description = "Client library for Microsoft Azure Storage services owning the azure.storage namespace, user should not use this directly";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
  };
})
