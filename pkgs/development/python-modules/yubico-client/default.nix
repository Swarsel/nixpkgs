{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "yubico-client";
  version = "1.13.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-47hs0qEjEF7frK1AVRx7JunBGT2B/+Fo7nBOv9PREWI=";
  };

  # pypi package missing test_utils and github releases is behind
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "yubico_client" ];

  meta = {
    description = "Verifying Yubico OTPs based on the validation protocol version 2.0";
    homepage = "https://github.com/Kami/python-yubico-client/";
    license = lib.licenses.bsd3;
  };
})
