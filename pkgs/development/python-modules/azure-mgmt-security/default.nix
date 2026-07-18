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
  pname = "azure-mgmt-security";
  version = "7.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WRLu1+nTdY/cqNJuHcJrQZQ9xHAyCKEYQmbiwlLhrWY=";
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
    "azure.mgmt.security"
  ];

  meta = {
    description = "Microsoft Azure Security Center Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/security/azure-mgmt-security";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-security_${version}/sdk/security/azure-mgmt-security/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
