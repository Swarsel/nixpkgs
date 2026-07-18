{
  lib,
  fetchFromGitHub,
  blinker,
  buildPythonPackage,
  flask,
  flask-sqlalchemy,
  greenlet,
  setuptools,
  webtest,
}:

buildPythonPackage rec {
  pname = "flask-webtest";
  version = "0.1.6";

  # Pypi tarball doesn't include version.py
  src = fetchFromGitHub {
    owner = "level12";
    repo = "flask-webtest";
    tag = version;
    hash = "sha256-wcEc9j62bQXAmXczsunITQP3sU040d6Ws8cz0w7+5r4=";
  };

  nativeCheckInputs = [
    flask-sqlalchemy
    greenlet
  ];

  build-system = [ setuptools ];

  dependencies = [
    flask
    webtest
    blinker
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_webtest" ];

  meta = {
    description = "Utilities for testing Flask applications with WebTest";
    homepage = "https://github.com/level12/flask-webtest";
    changelog = "https://github.com/level12/flask-webtest/blob/${src.rev}/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
