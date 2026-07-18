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
  pname = "azure-mgmt-recoveryservicesbackup";
  version = "10.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DKw8a4cjBjWbvEdQHRhLcAhGzlSPk/nA9u99HRC3I+k=";
    pname = "azure_mgmt_recoveryservicesbackup";
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
  pythonImportsCheck = [ "azure.mgmt.recoveryservicesbackup" ];

  meta = {
    description = "This is the Microsoft Azure Recovery Services Backup Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-recoveryservicesbackup_${version}/sdk/recoveryservices/azure-mgmt-recoveryservicesbackup/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
