{
  lib,
  azure-common,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-loganalytics";
  version = "0.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-aP+5oiBuBrlnIQCo5jUcwE91u4GGfzDUFsaLVdYk15M=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    azure-common
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.loganalytics" ];
  pythonNamespaces = [ "azure" ];

  meta = {
    description = "This is the Microsoft Azure Log Analytics Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      maxwilson
    ];
  };
})
