{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  msrest,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "vsts-cd-manager";
  version = "1.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-C7CQWc1VPhwgbpLvMkyw3PkjNIRtZGxExoT2JWuGRHs=";
  };

  # no tests included
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    msrest
    mock
  ];

  pyproject = true;
  pythonImportsCheck = [ "vsts_cd_manager" ];

  meta = {
    description = "Microsoft Azure API Management Client Library for Python";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
