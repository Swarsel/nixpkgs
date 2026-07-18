{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-dashboard";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-1LASBzs+biyDDQPoCujcvLhK3iyNaHLU8VCtBSdTJxg=";
    dist = "py3";
    format = "wheel";
    pname = "azure_mgmt_dashboard";
    python = "py3";
  };

  propagatedBuildInputs = [
    azure-common
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  # Module has no tests
  doCheck = false;
  format = "wheel";
  pythonImportsCheck = [ "azure.mgmt.dashboard" ];

  meta = {
    description = "Microsoft Azure Dashboard Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/dashboard/azure-mgmt-dashboard/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ techknowlogick ];
  };
}
