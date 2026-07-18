{
  lib,
  azure-common,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-devspaces";
  version = "0.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-87TIvgadTe7CP47HX1zJnZh5XXyVtSHXe0EeFFPWcjc=";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrestazure
    azure-common
    azure-mgmt-nspkg
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.devspaces" ];

  meta = {
    description = "This is the Microsoft Azure Dev Spaces Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
