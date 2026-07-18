{
  lib,
  fetchFromGitHub,
  # dependencies
  apache-tvm-ffi,
  buildPythonPackage,
  einops,
  # optional-dependencies
  # nvidia-matmul-heuristics,
  jax,
  nvidia-cutlass-dsl,
  # jax-tvm-ffi,
  pandas,
  # build-system
  setuptools,
  torch,
  torch-c-dlpack-ext,
}:
buildPythonPackage (finalAttrs: {
  pname = "quack-kernels";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "Dao-AILab";
    repo = "quack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L6kReIaCTVxJPYkkYn5aCXCChAsaxn/ikcBHTHzDmgs=";
  };

  # Fatal Python error: Aborted
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    apache-tvm-ffi
    einops
    nvidia-cutlass-dsl
    torch
    torch-c-dlpack-ext
  ];

  optional-dependencies = {
    bench = [
      pandas
    ];

    heuristics = [
      # nvidia-matmul-heuristics
    ];

    jax = [
      jax
      # jax-tvm-ffi
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "quack" ];

  meta = {
    description = "Quirky Assortment of CuTe Kernels";
    homepage = "https://github.com/Dao-AILab/quack";
    changelog = "https://github.com/Dao-AILab/quack/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      GaetanLepage
      prince213
    ];
  };
})
