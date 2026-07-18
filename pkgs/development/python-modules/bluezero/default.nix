{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pygobject3,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bluezero";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "ukBaz";
    repo = "python-bluezero";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H5760bPdA7NECiOWI7fLCxW3K7+c2L0Y3sa/E/krJJw=";
  };

  # Most of the tests are failing due to a missing working dbus instance and bluetooth devices
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    pygobject3
  ];

  pyproject = true;

  pythonImportsCheck = [
    "bluezero"
  ];

  pythonRelaxDeps = [ "pygobject" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A simple Python interface to Bluez";
    homepage = "https://github.com/ukBaz/python-bluezero";
    changelog = "https://github.com/ukBaz/python-bluezero/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
