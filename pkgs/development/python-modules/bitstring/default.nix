{
  lib,
  fetchFromGitHub,
  bitarray,
  buildPythonPackage,
  pytest-benchmark,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bitstring";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "scott-griffiths";
    repo = "bitstring";
    tag = "bitstring-${version}";
    hash = "sha256-ZABAd42h+BqcpKTFV5PxcBN3F8FKV6Qw3rhP13eX57k=";
  };

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ bitarray ];

  disabledTestPaths = [
    "tests/test_bits.py"
    "tests/test_fp8.py"
    "tests/test_mxfp.py"
  ];

  pyproject = true;

  pytestFlags = [
    "--benchmark-disable"
  ];

  pythonImportsCheck = [ "bitstring" ];
  pythonRelaxDeps = [ "bitarray" ];

  meta = {
    description = "Module for binary data manipulation";
    homepage = "https://github.com/scott-griffiths/bitstring";
    changelog = "https://github.com/scott-griffiths/bitstring/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.unix;
  };
}
