{
  lib,
  azure-nspkg,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  isPyPy,
  python,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-common";
  version = "1.1.28";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-SsDNMhTja2obakQmhnIqXYzESWA6qDPz8PQL2oNnBKM=";
    extension = "zip";
  };

  doCheck = false;

  postInstall = lib.optionalString (!isPy3k) ''
    echo "__import__('pkg_resources').declare_namespace(__name__)" >> "$out/${python.sitePackages}"/azure/__init__.py
  '';

  build-system = [ setuptools ];
  dependencies = [ azure-nspkg ] ++ lib.optionals (!isPy3k) [ setuptools ]; # need for namespace lookup
  disabled = isPyPy;
  pyproject = true;

  meta = {
    description = "This is the Microsoft Azure common code";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      olcai
      maxwilson
    ];
  };
})
