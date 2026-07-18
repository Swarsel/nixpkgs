{
  lib,
  buildPythonPackage,
  fetchPypi,
  pbr,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lockfile";
  version = "0.12.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-au0C3gPLok76vNYAswVAFAY0/AbPpgOCLVCNU2Hp95k=";
  };

  patches = [ ./fix-tests.patch ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    pbr
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Platform-independent advisory file locking capability for Python applications";
    homepage = "https://launchpad.net/pylockfile";
    license = lib.licenses.asl20;
  };
}
