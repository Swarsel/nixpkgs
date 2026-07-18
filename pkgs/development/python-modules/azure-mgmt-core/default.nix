{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-core";
  version = "1.6.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-smIyr4V7Ah5h2BPZ9K5TBGUlXLELPd6UWtN0P3pY55w=";
    extension = "tar.gz";
    pname = "azure_mgmt_core";
  };

  # not included
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-core
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.mgmt.core"
    "azure.core"
  ];

  pythonNamespaces = "azure.mgmt";

  meta = {
    description = "Microsoft Azure Management Core Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
