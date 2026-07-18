{
  lib,
  # pythonPackages
  azure-nspkg,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-keyvault-nspkg";
  version = "1.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-rGi4iqucbK9Uoj2iodHHGNdSC65a3/BN0KdDIoJptkE=";
    extension = "zip";
  };

  # Just a namespace package, no tests exist:
  #   https://github.com/Azure/azure-sdk-for-python/blob/master/sdk/keyvault/tests.yml
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ azure-nspkg ];
  pyproject = true;

  meta = {
    description = "Microsoft Azure Key Vault Namespace Package [Internal]";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
  };
})
