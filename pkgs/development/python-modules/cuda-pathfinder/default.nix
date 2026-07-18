{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytest-mock,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "cuda-pathfinder";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cuda-python";
    tag = "cuda-pathfinder-v${finalAttrs.version}";
    hash = "sha256-okhlkeS7vmH5nUFvND6stB5FoyGAsO1VimWRgFxqHKU=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cuda"
    "cuda.pathfinder"
  ];

  sourceRoot = "${finalAttrs.src.name}/cuda_pathfinder";

  meta = {
    description = "one-stop solution for locating CUDA components";
    homepage = "https://github.com/NVIDIA/cuda-python/tree/main/cuda_pathfinder";
    changelog = "https://nvidia.github.io/cuda-python/cuda-pathfinder/${finalAttrs.version}/release/${finalAttrs.version}-notes.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
})
