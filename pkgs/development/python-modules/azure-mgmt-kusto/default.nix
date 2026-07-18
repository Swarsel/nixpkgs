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
  pname = "azure-mgmt-kusto";
  version = "3.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-K8keApefYp/u7cTZuWNYhltVlFethunG+ccJpAgyDmM=";
    pname = "azure_mgmt_kusto";
  };

  # no tests included
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.common"
    "azure.mgmt.kusto"
  ];

  meta = {
    description = "Microsoft Azure Kusto Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-kusto_${version}/sdk/kusto/azure-mgmt-kusto/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
