{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  hatchling,
  mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-vapid";
  version = "1.9.4";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-oAQCNWDLxU40/AY4CgWA8E/8x4joT7bRnpM57rZVGig=";
    pname = "py_vapid";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ cryptography ];
  pyproject = true;

  meta = {
    description = "Library for VAPID header generation";
    homepage = "https://github.com/mozilla-services/vapid";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "vapid";
  };
})
