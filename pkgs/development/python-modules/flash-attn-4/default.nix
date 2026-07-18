{
  lib,
  fetchFromGitHub,
  # dependencies
  apache-tvm-ffi,
  buildPythonPackage,
  cuda-bindings,
  einops,
  # passthru
  nix-update-script,
  nvidia-cutlass-dsl,
  quack-kernels,
  # build-system
  setuptools,
  setuptools-scm,
  torch,
  torch-c-dlpack-ext,
}:
buildPythonPackage (finalAttrs: {
  pname = "flash-attn-4";
  version = "4.0.0.beta20";

  src = fetchFromGitHub {
    owner = "Dao-AILab";
    repo = "flash-attention";
    tag = "fa4-v${finalAttrs.version}";
    hash = "sha256-Joo6WJHuAlj8icQHFtmd3XxklhGTvOG4Z5r/86KJ9VQ=";
  };

  # No tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    apache-tvm-ffi
    cuda-bindings
    einops
    nvidia-cutlass-dsl
    quack-kernels
    torch
    torch-c-dlpack-ext
  ];

  pyproject = true;
  pythonImportsCheck = [ "flash_attn.cute" ];
  # FA4 is a separate distribution shipped under flash_attn/cute/ with its own pyproject.toml.
  # The top-level setup.py builds the classic compiled flash-attn and excludes flash_attn.cute.
  sourceRoot = "${finalAttrs.src.name}/flash_attn/cute";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex=fa4-v(.*)"
      "--version=unstable"
    ];
  };

  meta = {
    description = "CuTeDSL-based implementation of FlashAttention for Hopper and Blackwell GPUs";
    homepage = "https://github.com/Dao-AILab/flash-attention/tree/main/flash_attn/cute";
    changelog = "https://github.com/Dao-AILab/flash-attention/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      GaetanLepage
      prince213
    ];
  };
})
