{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  glibcLocales,
  mock,
  pycrypto,
  pylibmc,
  pymongo,
  pytestCheckHook,
  python-memcached,
  redis,
  setuptools,
  sqlalchemy,
  webtest,
}:

buildPythonPackage rec {
  pname = "beaker";
  version = "1.13.0";

  # The pypy release do not contains the tests
  src = fetchFromGitHub {
    owner = "bbangert";
    repo = "beaker";
    tag = version;
    hash = "sha256-HzjhOPXElwKoJLrhGIbVn798tbX/kaS1EpQIX+vXCtE=";
  };

  nativeCheckInputs = [
    glibcLocales
    python-memcached
    mock
    pylibmc
    pymongo
    redis
    webtest
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    sqlalchemy
    pycrypto
    cryptography
  ];

  # Can not run memcached tests because it immediately tries to connect.
  # Disable external tests because they need to connect to a live database.
  disabledTestPaths = [
    "tests/test_memcached.py"
    "tests/test_managers/test_ext_*"
  ];

  pyproject = true;

  meta = {
    description = "Session and Caching library with WSGI Middleware";
    homepage = "https://github.com/bbangert/beaker";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    knownVulnerabilities = [ "CVE-2013-7489" ];
  };
}
