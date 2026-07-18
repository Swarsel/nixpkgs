{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lit";
  version = "18.1.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-R8F0oYaUGugw8E3tdqNERgC+Z9Xl+4KCw3g/umccTts=";
  };

  nativeBuildInputs = [ setuptools ];
  # Non-standard test suite. Needs custom checkPhase.
  # Needs LLVM's `FileCheck` and `not`: `$out/bin/lit tests`
  # There should be `llvmPackages.lit` since older LLVM versions may
  # have the possibility of not correctly interfacing with newer lit versions
  doCheck = false;
  pyproject = true;

  passthru = {
    inherit python;
  };

  meta = {
    description = "Portable tool for executing LLVM and Clang style test suites";
    homepage = "http://llvm.org/docs/CommandGuide/lit.html";
    license = lib.licenses.ncsa;
    maintainers = [ ];
    mainProgram = "lit";
  };
}
