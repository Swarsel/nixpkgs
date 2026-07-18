{
  lib,
  azure-nspkg,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-nspkg";
  version = "3.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-iyKH9nFSlQWylgBebekVCwdDRMLH0cgFs/BT0IHVjFI=";
    extension = "zip";
  };

  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ azure-nspkg ];
  pyproject = true;

  meta = {
    description = "Microsoft Azure SDK for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      olcai
      maxwilson
    ];
  };
})
