{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-datalake-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrestazure,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-datalake-store";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-GrmVK97M+iojevPLVTuLmfQRLxvrHtr9DRHymJvLYHE=";
    extension = "zip";
  };

  propagatedBuildInputs = [
    msrestazure
    azure-common
    azure-mgmt-core
    azure-mgmt-datalake-nspkg
  ];

  # has no tests
  doCheck = false;
  format = "setuptools";
  pythonNamespaces = [ "azure.mgmt.datalake" ];

  meta = {
    description = "This is the Microsoft Azure Data Lake Store Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      maxwilson
    ];
  };
}
