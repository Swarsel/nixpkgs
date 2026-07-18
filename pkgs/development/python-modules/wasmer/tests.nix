{
  buildPythonPackage,
  pytestCheckHook,
  wasmer,
  wasmer-compiler-cranelift,
  wasmer-compiler-llvm,
  wasmer-compiler-singlepass,
}:

buildPythonPackage {
  inherit (wasmer) version;
  pname = "wasmer-tests";
  src = wasmer.testsout;

  nativeCheckInputs = [
    pytestCheckHook
    wasmer
    wasmer-compiler-cranelift
    wasmer-compiler-llvm
    wasmer-compiler-singlepass
  ];

  dontBuild = true;
  dontInstall = true;
  format = "setuptools";
}
