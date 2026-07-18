{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cuda-bindings,
  cuda-pathfinder,
  networkx,
  numpy,
  pydot,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  torch,
  treelib,
}:

buildPythonPackage (finalAttrs: {
  pname = "nvidia-cutlass";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cutlass";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XicHeV9ni9bSOWcUJM8HrCuz61mVK1EdZ9uxNvgWmvk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    torch
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    cuda-bindings
    cuda-pathfinder
    networkx
    numpy
    pydot
    scipy
    treelib
  ];

  enabledTestPaths = [
    "test"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cutlass_cppgen"
    "cutlass_library"
    "pycute"
  ];

  pythonRemoveDeps = [
    # Replaced with the cuda-python sub-packages we actually need
    "cuda-python"
  ];

  meta = {
    description = "Python bindings for NVIDIA's CUTLASS library";
    homepage = "https://github.com/NVIDIA/cutlass";
    changelog = "https://github.com/NVIDIA/cutlass/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
