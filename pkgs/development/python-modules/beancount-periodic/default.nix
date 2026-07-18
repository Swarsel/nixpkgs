{
  lib,
  fetchFromGitHub,
  beancount,
  beangulp,
  buildPythonPackage,
  python-dateutil,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "beancount-periodic";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "dallaslu";
    repo = "beancount-periodic";
    tag = "v${version}";
    hash = "sha256-XuBDKG/iOS0gyfiwEEPjIckAbnfOKHjYwXW4CmUy8eA=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    beancount
    beangulp
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "beancount_periodic" ];

  unittestFlags = [
    "-v"
    "tests"
  ];

  meta = {
    description = "Beancount plugin to generate periodic transactions";
    homepage = "https://github.com/dallaslu/beancount-periodic";
    license = with lib.licenses; [ unlicense ];
    maintainers = with lib.maintainers; [ polyfloyd ];
  };
}
