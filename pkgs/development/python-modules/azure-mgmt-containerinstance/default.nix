{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  msrestazure,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-containerinstance";
  version = "10.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eNQ3rbKFdPRIyDjtXwH5ztN4GWCYBh3rWdn3AxcEwX4=";
    extension = "zip";
  };

  propagatedBuildInputs = [
    msrest
    msrestazure
    azure-common
    azure-mgmt-core
  ];

  # has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "azure.mgmt.containerinstance" ];

  meta = {
    description = "This is the Microsoft Azure Container Instance Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
