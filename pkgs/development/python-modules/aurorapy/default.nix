{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  pyserial,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "aurorapy";
  version = "0.3";

  src = fetchFromGitLab {
    owner = "energievalsabbia";
    repo = "aurorapy";
    tag = finalAttrs.version;
    hash = "sha256-bc5i2x35sZXkCSJraTqX3Zc5B9eKL1qDh97/7ixyHLY=";
  };

  postPatch = ''
    sed -i "/from past.builtins import map/d" aurorapy/client.py
  '';

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "aurorapy" ];
  pythonRemoveDeps = [ "future" ];

  meta = {
    description = "Implementation of the communication protocol for Power-One Aurora inverters";
    homepage = "https://gitlab.com/energievalsabbia/aurorapy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
