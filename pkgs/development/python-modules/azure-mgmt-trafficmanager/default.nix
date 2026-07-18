{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  msrest,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-trafficmanager";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Nb8ZAr8VidYm41lx5aqgCeiECUZytHm3mM0buNTy/fk=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    msrestazure
    azure-common
    azure-mgmt-core
  ]
  ++ lib.optionals (!isPy3k) [ azure-mgmt-nspkg ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.trafficmanager" ];

  meta = {
    description = "This is the Microsoft Azure Traffic Manager Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
