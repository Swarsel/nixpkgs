{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  mako,
  nanobind,
  ninja,
  numpy,
  ocl-icd,
  # buildInputs
  opencl-headers,
  # dependencies
  platformdirs,
  pocl,
  pybind11,
  # tests
  pytestCheckHook,
  pytools,
  scikit-build-core,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyopencl";
  version = "2026.1.2";

  src = fetchFromGitHub {
    owner = "inducer";
    repo = "pyopencl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n1xdJbq+RPW2p8MNc6YA9+GlYokSbW8llbCFFv1wCcE=";
    fetchSubmodules = true;
  };

  buildInputs = [
    opencl-headers
    ocl-icd
    pybind11
  ];

  env = {
    CL_INC_DIR = "${opencl-headers}/include";
    CL_LIBNAME = "${ocl-icd}/lib/libOpenCL${stdenv.hostPlatform.extensions.sharedLibrary}";
    CL_LIB_DIR = "${ocl-icd}/lib";
  };

  nativeCheckInputs = [
    pocl
    mako
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    rm -rf pyopencl
  '';

  build-system = [
    cmake
    nanobind
    ninja
    numpy
    scikit-build-core
  ];

  dependencies = [
    numpy
    platformdirs
    pytools
    typing-extensions
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "pyopencl"
    "pyopencl.array"
    "pyopencl.cltypes"
    "pyopencl.compyte"
    "pyopencl.elementwise"
    "pyopencl.tools"
  ];

  meta = {
    description = "Python wrapper for OpenCL";
    homepage = "https://github.com/pyopencl/pyopencl";
    changelog = "https://github.com/inducer/pyopencl/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
