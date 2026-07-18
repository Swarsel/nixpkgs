{
  lib,
  azure-common,
  azure-mgmt-nspkg,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  msrestazure,
  python,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-common";
  version = "0.20.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-xjgSwT2fNmFcB/h0vGArczu1FvHtYqtzGJuPcca/v+Y=";
    extension = "zip";
  };

  doCheck = false;

  postInstall = lib.optionalString (!isPy3k) ''
    echo "__import__('pkg_resources').declare_namespace(__name__)" >> "$out/${python.sitePackages}"/azure/mgmt/__init__.py
    echo "__import__('pkg_resources').declare_namespace(__name__)" >> "$out/${python.sitePackages}"/azure/__init__.py
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    azure-common
    azure-mgmt-nspkg
    requests
    msrestazure
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.common" ];

  meta = {
    description = "This is the Microsoft Azure Resource Management common code";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      olcai
      maxwilson
    ];
  };
})
