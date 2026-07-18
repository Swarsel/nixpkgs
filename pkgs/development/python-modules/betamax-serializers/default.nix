{
  lib,
  betamax,
  buildPythonPackage,
  fetchPypi,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "betamax-serializers";
  version = "0.2.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NFxBmxtzFx8pUcYqw8cBd1rEt24T6GRk6/D/KpeOSUk=";
  };

  buildInputs = [
    betamax
    pyyaml
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "betamax_serializers" ];

  meta = {
    description = "Set of third-party serializers for Betamax";
    homepage = "https://gitlab.com/betamax/serializers";
    license = lib.licenses.asl20;
  };
})
