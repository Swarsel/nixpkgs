{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrestazure,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-consumption";
  version = "10.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BqCGQ2wXN/d6uGiU1R9Zc7bg+l7fVlWOTCllieurkTA=";
    extension = "zip";
  };

  preBuild = ''
    rm -f azure_bdist_wheel.py
  '';

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrestazure
    azure-common
    azure-mgmt-core
    azure-mgmt-nspkg
  ];

  pyproject = true;
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Consumption Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
