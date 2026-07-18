{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "iptools";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "bd808";
    repo = "python-iptools";
    tag = "v${version}";
    hash = "sha256-340Wc4QGwUqEEANM5EQzFaXxIWVf2fDr4qfCuxNEVBQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "tests/iptools/iptools_test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "iptools" ];

  meta = {
    description = "Utilities for manipulating IP addresses including a class that can be used to include CIDR network blocks in Django's INTERNAL_IPS setting";
    homepage = "https://github.com/bd808/python-iptools";
    license = lib.licenses.bsd0;
  };
}
