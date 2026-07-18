{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cyrus_sasl,
  gevent,
  openldap,
  pytestCheckHook,
  setuptools,
  tornado,
  trio,
}:

buildPythonPackage rec {
  pname = "bonsai";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "noirello";
    repo = "bonsai";
    tag = "v${version}";
    hash = "sha256-q0BE1TuxiS01Z83dqDH54XzRgdF3ZszRBJsMIfsvTeU=";
  };

  buildInputs = [
    cyrus_sasl
    openldap
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # requires running LDAP server
    "tests/test_asyncio.py"
    "tests/test_ldapclient.py"
    "tests/test_ldapconnection.py"
    "tests/test_ldapentry.py"
    "tests/test_ldapreference.py"
    "tests/test_pool.py"
  ];

  disabledTests = [
    # requires running LDAP server
    "test_set_async_connect"
  ];

  optional-dependencies = {
    gevent = [ gevent ];
    tornado = [ tornado ];
    trio = [ trio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bonsai" ];

  meta = {
    description = "Python 3 module for accessing LDAP directory servers";
    homepage = "https://github.com/noirello/bonsai";
    changelog = "https://github.com/noirello/bonsai/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
