{
  lib,
  azure-common,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrest,
  msrestazure,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-machinelearningcompute";
  version = "0.4.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-elL4VZERTvM6WZ2rvvhA2HK39Zm3gj5ZavlJDsUbhz8=";
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
    azure-mgmt-nspkg
  ];

  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure Machine Learning Compute Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
