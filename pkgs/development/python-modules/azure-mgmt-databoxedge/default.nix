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
  pname = "azure-mgmt-databoxedge";
  version = "2.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-8Y8GbQJ8maIkmY08R0CBJoIVmr44z1joewl3DKssrMA=";
    pname = "azure_mgmt_databoxedge";
  };

  # no tests in pypi tarball
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.databoxedge" ];

  meta = {
    description = "Microsoft Azure Databoxedge Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/databox/azure-mgmt-databox";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-databoxedge_${version}/sdk/databox/azure-mgmt-databox/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
