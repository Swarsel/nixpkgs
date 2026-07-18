{
  buildPythonPackage,
  # dependencies
  ml-dtypes,
  numpy,
  onnx, # pkgs.onnx
  # tests
  parameterized,
  pillow,
  protobuf,
  pytestCheckHook,
  typing-extensions,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage {
  inherit (onnx)
    pname
    src # Needed for testing.
    version
    ;

  buildInputs = [
    # onnx must be included to avoid shrinking during fixupPhase removing the RUNPATH entry on
    # onnx_cpp2py_export.cpython-*.so.
    onnx
  ];

  nativeCheckInputs = [
    parameterized
    pillow
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  # detecting source dir as a python package confuses pytest
  preCheck = ''
    rm onnx/__init__.py
  '';

  # The executables are just utility scripts that aren't too important
  postInstall = ''
    rm -rv $out/bin
  '';

  __darwinAllowLocalNetworking = true;

  dependencies = [
    ml-dtypes
    numpy
    protobuf
    typing-extensions
  ];

  dontUseWheelUnpack = true;

  enabledTestPaths = [
    "onnx/test"
    "examples"
  ];

  format = "wheel";

  postUnpack = ''
    cp -rv "${onnx.dist}" "$sourceRoot/dist"
    chmod +w "$sourceRoot/dist"
  '';

  pythonImportsCheck = [ "onnx" ];

  meta = {
    # Explicitly inherit from ONNX's meta to avoid pulling in attributes added by stdenv.mkDerivation.
    inherit (onnx.meta)
      changelog
      description
      homepage
      license
      maintainers
      ;
  };
}
