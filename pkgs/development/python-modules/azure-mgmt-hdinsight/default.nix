{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-hdinsight";
  version = "9.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QevcacDR+B0l3TBDjBT/9DMfZmOfVYBbkYuWSer/54o=";
    extension = "zip";
  };

  # no tests included
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-core
    msrest
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.mgmt.hdinsight"
  ];

  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "Microsoft Azure HDInsight Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/hdinsight/azure-mgmt-hdinsight";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-hdinsight_${version}/sdk/hdinsight/azure-mgmt-hdinsight/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
