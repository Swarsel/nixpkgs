{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-api-core,
  grpcio,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "chirpstack-api";
  version = "3.12.5";

  src = fetchFromGitHub {
    owner = "brocaar";
    repo = "chirpstack-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TDwvUNnGAbt10lLg6U7q+JMg7uu8TLySYqNyt/uk8UY=";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    google-api-core
    grpcio
  ];

  pyproject = true;
  pythonImportsCheck = [ "chirpstack_api" ];
  sourceRoot = "${finalAttrs.src.name}/python/src";

  meta = {
    description = "ChirpStack gRPC API message and service wrappers for Python";
    homepage = "https://github.com/brocaar/chirpstack-api";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
