{
  lib,
  azure-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "azure-keyvault-securitydomain";
  version = "1.0.0b1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MpGhked4qUfkso7QEyeJKpOu3PjgoN1nTPEWyxEEN3Y=";
    pname = "azure_keyvault_securitydomain";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    azure-core
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.keyvault.securitydomain"
  ];

  meta = {
    description = "Microsoft Corporation Azure Keyvault Securitydomain Client Library for Python";
    homepage = "https://pypi.org/project/azure-keyvault-securitydomain/1.0.0b1/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ katexochen ];
  };
}
