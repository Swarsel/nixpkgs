{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyserial,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyrfxtrx";
  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pyRFXtrx";
    tag = version;
    hash = "sha256-6gD6ch7DyaD9nCY/VfyJHmV4gEDPsDfVKjNaNedmVVE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;

  meta = {
    description = "Library to communicate with the RFXtrx family of devices";
    homepage = "https://github.com/Danielhiversen/pyRFXtrx";
    changelog = "https://github.com/Danielhiversen/pyRFXtrx/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
