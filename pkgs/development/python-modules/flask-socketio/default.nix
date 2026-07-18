{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  pytestCheckHook,
  python-socketio,
  redis,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-socketio";
  version = "5.6.1";

  src = fetchFromGitHub {
    owner = "miguelgrinberg";
    repo = "Flask-SocketIO";
    tag = "v${version}";
    hash = "sha256-tTpogVhyMNLLtK3UDOtZD2m2zIbcIAc9Opa/1xdJRa8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    redis
  ];

  build-system = [ setuptools ];

  dependencies = [
    flask
    python-socketio
  ];

  enabledTestPaths = [ "test_socketio.py" ];
  pyproject = true;
  pythonImportsCheck = [ "flask_socketio" ];

  meta = {
    description = "Socket.IO integration for Flask applications";
    homepage = "https://github.com/miguelgrinberg/Flask-SocketIO/";
    changelog = "https://github.com/miguelgrinberg/Flask-SocketIO/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
  };
}
