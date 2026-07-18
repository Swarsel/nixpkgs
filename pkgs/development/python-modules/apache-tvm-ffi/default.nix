{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  cython,
  ninja,
  # tests
  numpy,
  pytestCheckHook,
  scikit-build-core,
  setuptools-scm,
  # dependencies
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "apache-tvm-ffi";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "tvm-ffi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZFi7MKFiHK2lNoVkQbPhOc7NpIf24PLLP8SqGQiQ9Lw=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    numpy
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    cmake
    cython
    ninja
    scikit-build-core
    setuptools-scm
  ];

  dependencies = [
    typing-extensions
  ];

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    cpp = [
      ninja
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tvm_ffi" ];

  meta = {
    description = "Open ABI and FFI for Machine Learning Systems";
    homepage = "https://github.com/apache/tvm-ffi";
    changelog = "https://github.com/apache/tvm-ffi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
