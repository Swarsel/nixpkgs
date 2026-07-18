{
  lib,
  buildPythonPackage,
  fetchPypi,
  # Test inputs
  flask,
  flask-restful,
  importlib-metadata,
  netaddr,
  pbr,
  pecan,
  pytestCheckHook,
  setuptools,
  simplegeneric,
  sphinx,
  transaction,
  webtest,
}:

buildPythonPackage (finalAttrs: {
  pname = "wsme";
  version = "0.12.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-m36yJErzxwSskUte0iGVS7aK3QqLKy84okSwZ7M3mS0=";
    pname = "WSME";
  };

  nativeBuildInputs = [ pbr ];

  nativeCheckInputs = [
    pytestCheckHook
    flask
    flask-restful
    pecan
    sphinx
    transaction
    webtest
  ];

  build-system = [ setuptools ];

  dependencies = [
    importlib-metadata
    simplegeneric
    netaddr
  ];

  enabledTestPaths = [
    "wsme/tests"
    "tests/pecantest"
    "tests/test_sphinxext.py"
    "tests/test_flask.py"
  ];

  pyproject = true;

  meta = {
    description = "Simplify the writing of REST APIs, and extend them with additional protocols";
    homepage = "https://pythonhosted.org/WSME/";
    changelog = "https://pythonhosted.org/WSME/changes.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
