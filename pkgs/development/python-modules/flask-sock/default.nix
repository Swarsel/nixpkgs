{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  pytestCheckHook,
  setuptools,
  simple-websocket,
}:

buildPythonPackage rec {
  pname = "flask-sock";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "miguelgrinberg";
    repo = "flask-sock";
    rev = "v${version}";
    hash = "sha256-GKfOVdeLPag2IKGCWrMjQp4NTL1/9GiyLhXhf9jQKhQ=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    flask
    simple-websocket
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  enabledTestPaths = [ "tests/test_flask_sock.py" ];
  pyproject = true;
  pythonImportsCheck = [ "flask_sock" ];

  meta = {
    description = "WebSocket support for Flask";
    homepage = "https://github.com/miguelgrinberg/flask-sock/";
    changelog = "https://github.com/miguelgrinberg/flask-sock/blob/main/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fmhoeger ];
  };
}
