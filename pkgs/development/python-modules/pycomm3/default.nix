{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycomm3";
  version = "1.2.16";

  src = fetchFromGitHub {
    owner = "ottowayi";
    repo = "pycomm3";
    tag = "v${version}";
    hash = "sha256-xcN0TKwWg23CDBmwMRZlPFuKYpeLg7KSXzhRtNuP6Ls=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # Don't test examples as some have additional requirements
    "examples/"
    # No physical PLC available
    "tests/online/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycomm3" ];

  meta = {
    description = "Python Ethernet/IP library for communicating with Allen-Bradley PLCs";
    homepage = "https://github.com/ottowayi/pycomm3";
    changelog = "https://github.com/ottowayi/pycomm3/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
