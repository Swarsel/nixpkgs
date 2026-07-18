{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  msrest,
  msrestazure,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-media";
  version = "10.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TVq/6dHttDGIUFzn8KTVeDTwcBMmphz3zrsGK7ux4aU=";
    extension = "zip";
  };

  propagatedBuildInputs = [
    msrest
    msrestazure
    azure-common
    azure-mgmt-core
  ];

  # has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "azure.mgmt.media" ];

  meta = {
    description = "This is the Microsoft Azure Media Services Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
