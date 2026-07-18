{
  lib,
  fetchFromGitHub,
  # buildInputs
  blas,
  buildPythonPackage,
  # build-system
  cmake,
  ninja,
  numpy,
  scikit-build-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "sparsediffpy";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "SparseDifferentiation";
    repo = "SparseDiffPy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PqtD3FjOpYLuu5ddeTdJ1UcL4Wvcv6RoZFGchpVdBAI=";
    # SparseDiffEngine is built from source and their cmake does not support finding it on the
    # system. We fallback to using the git submodule approach for now.
    fetchSubmodules = true;
  };

  buildInputs = [
    blas
  ];

  # No tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    numpy
    scikit-build-core
  ];

  dependencies = [
    numpy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "sparsediffpy" ];

  meta = {
    description = "Python bindings for SparseDiffEngine, a C library for computing sparse Jacobians and Hessians";
    homepage = "https://github.com/SparseDifferentiation/SparseDiffPy";
    changelog = "https://github.com/SparseDifferentiation/SparseDiffPy/blob/${finalAttrs.src.tag}/RELEASES.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
