{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  msrest,
  setuptools,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-mysqlflexibleservers";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0HemVoiKXFl39HmiRKZKxKHTUQAumaft2vakmoIZLlY=";
    pname = "azure_mgmt_mysqlflexibleservers";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    azure-common
    azure-mgmt-core
    isodate
    msrest
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.mgmt.mysqlflexibleservers"
  ];

  meta = {
    description = "Microsoft Azure Mysqlflexibleservers Management Client Library for Python";
    homepage = "https://pypi.org/project/azure-mgmt-mysqlflexibleservers/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
