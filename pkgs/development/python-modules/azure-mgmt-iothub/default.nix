{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-iothub";
  version = "4.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-B/Jb1vZzdLqxfMEZL5+SGzUONWAlHxkGnmZlg1Qe1Ng=";
    pname = "azure_mgmt_iothub";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.iothub" ];

  meta = {
    description = "This is the Microsoft Azure IoTHub Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/iothub/azure-mgmt-iothub";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-iothub_${version}/sdk/iothub/azure-mgmt-iothub/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
