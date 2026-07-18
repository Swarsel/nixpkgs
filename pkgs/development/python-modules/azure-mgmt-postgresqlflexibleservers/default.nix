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
  pname = "azure-mgmt-postgresqlflexibleservers";
  version = "3.0.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Vo1/vuxAAgVznCppDZCTygNFAMl5uopc3QbiEeFbLv8=";
    pname = "azure_mgmt_postgresqlflexibleservers";
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
    "azure.mgmt.postgresqlflexibleservers"
  ];

  meta = {
    description = "Microsoft Azure Postgresqlflexibleservers Management Client Library for Python";
    homepage = "https://pypi.org/project/azure-mgmt-postgresqlflexibleservers/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
