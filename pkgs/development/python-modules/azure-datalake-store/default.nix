{
  lib,
  adal,
  azure-common,
  buildPythonPackage,
  fetchPypi,
  msal,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-datalake-store";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-U2TURFqrFUocfLECFWKcPORs5ceqrxYHGJDAP65ToDU=";
    pname = "azure_datalake_store";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    adal
    azure-common
    msal
    requests
  ];

  pyproject = true;

  meta = {
    description = "This project is the Python filesystem library for Azure Data Lake Store";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
