{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-hybridcompute";
  version = "9.1.0b2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bKv4A6PjN6fMpyso0JqewADcKGOK1wXlULtkZpzrilY=";
    dist = "py3";
    format = "wheel";
    pname = "azure_mgmt_hybridcompute";
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
  pythonImportsCheck = [ "azure.mgmt.hybridcompute" ];

  meta = {
    description = "Microsoft Azure Hybrid Compute Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/hybridcompute/azure-mgmt-hybridcompute/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ techknowlogick ];
  };
}
