{
  lib,
  bleak,
  buildPythonPackage,
  cryptography,
  esptool,
  fetchPypi,
  netifaces,
  pyserial,
  replaceVars,
  setuptools,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "rns";
  version = "1.3.8";

  src = fetchPypi {
    hash = "sha256-1cHzlJOqm3WrZ7g5l9StW9NX5n6dYp/6KU4xov/eNH0=";
    pname = "rns";
    version = finalAttrs.version;
  };

  patches = [
    (replaceVars ./unvendor-esptool.patch {
      esptool = lib.getExe esptool;
    })
  ];

  nativeCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    bleak
    cryptography
    netifaces
    pyserial
  ];

  pyproject = true;
  pythonImportsCheck = [ "RNS" ];
  versionCheckProgram = "${placeholder "out"}/bin/rncp";

  meta = {
    description = "Cryptography-based networking stack for wide-area networks";
    homepage = "https://reticulum.network";
    changelog = "https://github.com/markqvist/Reticulum/blob/${finalAttrs.version}/Changelog.md";
    license = lib.licenses.reticulum;

    maintainers = with lib.maintainers; [
      drupol
      fab
      qbit
    ];
  };
})
