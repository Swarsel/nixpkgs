{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  calmsize,
  pandas,
  pytestCheckHook,
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytorch-memlab";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "Stonesjtu";
    repo = "pytorch_memlab";
    tag = finalAttrs.version;
    hash = "sha256-46C/2RvzhbHt1IHPmPCrLsIk2D3POhzuADNaXqUe0F4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    calmsize
    pandas
    torch
  ];

  # These tests require CUDA
  disabledTestPaths = [
    "test/test_courtesy.py"
    "test/test_line_profiler.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytorch_memlab" ];

  meta = {
    description = "Simple and accurate CUDA memory management laboratory for pytorch";
    homepage = "https://github.com/Stonesjtu/pytorch_memlab";
    changelog = "https://github.com/Stonesjtu/pytorch_memlab/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jherland ];
  };
})
