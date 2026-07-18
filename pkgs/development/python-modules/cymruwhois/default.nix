{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  python-memcached,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cymruwhois";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "JustinAzoff";
    repo = "python-cymruwhois";
    tag = version;
    hash = "sha256-d9m668JYI9mxUycoVWyaDCR7SOca+ebymZxWtgSPWNU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # £Failed: 'yield' keyword is allowed in fixtures, but not in tests (test_common)
    "tests/test_common_lookups.py"
  ];

  disabledTests = [
    # AssertionError
    "test_doctest"
  ];

  optional-dependencies = {
    CACHE = [ python-memcached ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cymruwhois" ];

  meta = {
    description = "Python client for the whois.cymru.com service";
    homepage = "https://github.com/JustinAzoff/python-cymruwhois";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
