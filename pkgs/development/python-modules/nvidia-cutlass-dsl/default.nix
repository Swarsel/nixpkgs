{
  lib,
  buildPythonPackage,
  fetchPypi,

  # dependencies
  nvidia-cutlass-dsl-libs-base,
}:

buildPythonPackage (finalAttrs: {
  inherit (nvidia-cutlass-dsl-libs-base) version;
  pname = "nvidia-cutlass-dsl";

  # Universal metadata-only wheel that just pulls in `nvidia-cutlass-dsl-libs-base`
  # (which actually ships the Python code and the bundled MLIR/CUDA runtime libs).
  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-mN/UD6vGwNthDu6upAPwu54q7AvGma4M30dfpKVHEMo=";
    dist = "py3";
    format = "wheel";
    pname = "nvidia_cutlass_dsl";
    python = "py3";
  };

  # No tests in the Pypi archive
  doCheck = false;

  dependencies = [
    nvidia-cutlass-dsl-libs-base
  ];

  format = "wheel";
  pythonImportsCheck = [ "cutlass" ];

  meta = {
    description = "NVIDIA CUTLASS Python DSL";
    homepage = "https://github.com/NVIDIA/cutlass";
    changelog = "https://github.com/NVIDIA/cutlass/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.unfreeRedistributable; # NVIDIA Proprietary
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
})
