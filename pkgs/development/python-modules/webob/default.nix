{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  legacy-cgi,
  # for passthru.tests
  pyramid,
  pytestCheckHook,
  routes,
  setuptools,
  tokenlib,
}:

buildPythonPackage rec {
  pname = "webob";
  version = "1.8.9";

  src = fetchFromGitHub {
    owner = "Pylons";
    repo = "webob";
    tag = version;
    hash = "sha256-axJQwlybuqBS6RgI2z9pbw58vHF9aC9AxCg13CIKCLs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  # https://github.com/Pylons/webob/issues/437
  dependencies = [ legacy-cgi ];

  disabledTestPaths = [
    # AttributeError: 'Thread' object has no attribute 'isAlive'
    "tests/test_in_wsgiref.py"
    "tests/test_client_functional.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "webob" ];

  passthru.tests = {
    inherit pyramid routes tokenlib;
  };

  meta = {
    description = "WSGI request and response object";
    homepage = "https://webob.org/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
