{
  lib,
  buildPythonPackage,
  canonicaljson,
  fetchPypi,
  pynacl,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  unpaddedbase64,
}:

buildPythonPackage (finalAttrs: {
  pname = "signedjson";
  version = "1.1.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-zZHFavU/Fp7wMsYunEoyktwViGaTMxjQWS40Yts9ZJI=";
    pname = "signedjson";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    canonicaljson
    unpaddedbase64
    pynacl
  ];

  pyproject = true;
  pythonImportsCheck = [ "signedjson" ];

  meta = {
    description = "Sign JSON with Ed25519 signatures";
    homepage = "https://github.com/matrix-org/python-signedjson";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
