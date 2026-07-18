{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cffi,
  # build-system
  cmake,
  # native dependencies
  libsamplerate,
  numpy,
  pybind11,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "samplerate";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "tuxu";
    repo = "python-samplerate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wetpPAoCenzOo6pD3+F0YNb/fc1BvaeKiw325C19rS0=";
  };

  # unvendor pybind11, libsamplerate
  postPatch = ''
    rm -r external
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_subdirectory(external)" "find_package(pybind11 REQUIRED)"
  '';

  buildInputs = [ libsamplerate ];
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf samplerate
  '';

  build-system = [
    cmake
    setuptools
    setuptools-scm
    pybind11
  ];

  dependencies = [
    cffi
    numpy
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # ValueError: cannot resize an array that references or is referenced
    "test_callback_with_2x"
    "test_process"
    "test_resize"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "samplerate" ];

  meta = {
    description = "Python bindings for libsamplerate based on CFFI and NumPy";
    homepage = "https://github.com/tuxu/python-samplerate";
    changelog = "https://github.com/tuxu/python-samplerate/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
