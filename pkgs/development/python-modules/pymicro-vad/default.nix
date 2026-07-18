{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  pybind11,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymicro-vad";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "rhasspy";
    repo = "pymicro-vad";
    tag = version;
    hash = "sha256-yKy/oD6nl2qZW64+aAHZRAEFextCXT6RpMfPThB8DXE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    pybind11
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymicro_vad" ];

  meta = {
    description = "Self-contained voice activity detector";
    homepage = "https://github.com/rhasspy/pymicro-vad";
    changelog = "https://github.com/rhasspy/pymicro-vad/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
