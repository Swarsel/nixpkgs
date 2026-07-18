{
  lib,
  azure-common,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-applicationinsights";
  version = "0.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-qIRbgDZbfyALrR9xqA0NMfO+wB7f1GfftsE+or1xupY=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    msrest
  ];

  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Application Insights Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
