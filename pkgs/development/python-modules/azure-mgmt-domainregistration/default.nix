{
  lib,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  nix-update-script,
  setuptools,
  typing-extensions,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-domainregistration";
  version = "1.0.0b1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9ayRrmCqmTY8yMLtrj/IIUb5xONb9SQoz8wvN29Wvy0=";
    pname = "azure_mgmt_domainregistration";
  };

  __structuredAttrs = true;

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    azure-mgmt-core
    isodate
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "azure.mgmt.domainregistration"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "This package will be released in the near future. Stay tuned";
    homepage = "https://pypi.org/project/azure-mgmt-domainregistration";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
