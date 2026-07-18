{
  lib,
  azure-common,
  buildPythonPackage,
  fetchPypi,
  msrest,
  msrestazure,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-graphrbac";
  version = "0.61.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-+yWwMwfhf3Ocga1r0+m1fFeENoYDHw8hS2UVhEfHc90=";
    pname = "azure_graphrbac";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    msrestazure
    azure-common
  ];

  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Graph RBAC Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python/tree/main/sdk/graphrbac/azure-graphrbac";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-graphrbac_${version}/sdk/graphrbac/azure-graphrbac/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
