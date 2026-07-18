{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "webdavclient3";
  version = "3.14.7";

  src = fetchFromGitHub {
    owner = "ezhov-evgeny";
    repo = "webdav-client-python-3";
    tag = "v${version}";
    hash = "sha256-On2vCV3iLxqLYKaiUkwry/lZFjhzlAlU2OYYq/7rrcE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    lxml
    python-dateutil
    requests
  ];

  disabledTestPaths = [
    # Tests require a local WebDAV instance
    "tests/test_client_it.py"
    "tests/test_client_resource_it.py"
    "tests/test_cyrilic_client_it.py"
    "tests/test_multi_client_it.py"
    "tests/test_tailing_slash_client_it.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "webdav3.client" ];

  meta = {
    description = "Easy to use WebDAV Client for Python 3.x";
    homepage = "https://github.com/ezhov-evgeny/webdav-client-python-3";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "wdc";
  };
}
