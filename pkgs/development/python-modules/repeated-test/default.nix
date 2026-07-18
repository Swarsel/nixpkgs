{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "repeated-test";
  version = "2.3.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3YPU8SL9rud5s0pnwwH5TJk1MXsDhdkDnZp/Oj6sgXs=";
    pname = "repeated_test";
  };

  nativeBuildInputs = [ setuptools-scm ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "repeated_test" ];

  meta = {
    description = "Unittest-compatible framework for repeating a test function over many fixtures";
    homepage = "https://github.com/epsy/repeated_test";
    changelog = "https://github.com/epsy/repeated_test/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
