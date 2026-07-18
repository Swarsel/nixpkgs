{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  numpy,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyedflib";
  version = "0.1.42";

  src = fetchFromGitHub {
    owner = "holgern";
    repo = "pyedflib";
    tag = "v${version}";
    hash = "sha256-KbySCsDjiS94U012KASRgHR2fuX090HlKUuPgsLC+xQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Otherwise, the module is imported from source and lacks the compiled artifacts
  # By moving to the pyedflib directory, python imports the installed package instead of the module
  # from the local files
  preCheck = ''
    cd pyedflib
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyedflib"
  ];

  meta = {
    description = "Python library to read/write EDF+/BDF+ files based on EDFlib";
    homepage = "https://github.com/holgern/pyedflib";
    changelog = "https://github.com/holgern/pyedflib/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
