{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  msrest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-recoveryservices";
  version = "4.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Y81Zbm/xuAHgYoPRU84Mfx1E9+3wUtMhwTJ0bDyMhx4=";
    pname = "azure_mgmt_recoveryservices";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    msrest
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.recoveryservices" ];

  meta = {
    description = "This is the Microsoft Azure Recovery Services Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-recoveryservices_${version}/sdk/recoveryservices/azure-mgmt-recoveryservices/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
