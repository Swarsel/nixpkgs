{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-nspkg";
  version = "3.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-59POpq9j5mfYe6HKT4zXy038pnjkxV/BztsyB2DjndA=";
    extension = "zip";
  };

  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
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
