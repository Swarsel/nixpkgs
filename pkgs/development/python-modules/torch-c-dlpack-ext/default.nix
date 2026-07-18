{
  lib,
  apache-tvm-ffi,
  buildPythonPackage,
  # build-system
  setuptools,
  # dependencies
  torch,
}:

buildPythonPackage (finalAttrs: {
  inherit (apache-tvm-ffi) version src;
  pname = "torch-c-dlpack-ext";
  # No tests
  doCheck = false;

  build-system = [
    apache-tvm-ffi
    setuptools
  ];

  dependencies = [
    torch
  ];

  pyproject = true;
  pythonImportsCheck = [ "torch_c_dlpack_ext" ];
  sourceRoot = "${finalAttrs.src.name}/addons/torch_c_dlpack_ext";

  meta = {
    description = "Ahead-Of-Time (AOT) compiled module to support faster DLPack conversion in DLPack";
    homepage = "https://github.com/apache/tvm-ffi/tree/main/addons/torch_c_dlpack_ext";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
