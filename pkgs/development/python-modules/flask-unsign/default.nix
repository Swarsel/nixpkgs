{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  itsdangerous,
  markupsafe,
  pytestCheckHook,
  requests,
  setuptools,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "flask-unsign";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "Paradoxis";
    repo = "Flask-Unsign";
    tag = "v${version}";
    hash = "sha256-/WK3g6Ef3mSKeT3aaSAh5J8estUN4sNmM9Tq9An/18A=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    flask
    itsdangerous
    markupsafe
    requests
    werkzeug
  ];

  enabledTestPaths = [ "tests/flask_unsign.py" ];
  pyproject = true;
  pythonImportsCheck = [ "flask_unsign" ];

  meta = {
    description = "Command line tool to fetch, decode, brute-force and craft session cookies of Flask applications";
    homepage = "https://github.com/Paradoxis/Flask-Unsign";
    changelog = "https://github.com/Paradoxis/Flask-Unsign/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "flask-unsign";
  };
}
