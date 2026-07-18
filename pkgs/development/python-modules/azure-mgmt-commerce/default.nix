{
  lib,
  azure-common,
  azure-mgmt-core,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  msrestazure,
  setuptools,
}:

buildPythonPackage rec {
  pname = "azure-mgmt-commerce";
  version = "6.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "6f5447395503b2318f451d24f8021ee08db1cac44f1c3337ea690700419626b6";
    extension = "zip";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    msrestazure
    azure-common
    azure-mgmt-core
    azure-mgmt-nspkg
  ];

  prePatch = ''
    rm -f azure_bdist_wheel.py tox.ini
    sed -i "/azure-namespace-package/c\ " setup.cfg
  '';

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.commerce" ];
  pythonNamespaces = [ "azure.mgmt" ];

  meta = {
    description = "This is the Microsoft Azure Commerce Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
}
