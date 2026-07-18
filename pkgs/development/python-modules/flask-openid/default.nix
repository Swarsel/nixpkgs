{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  python3-openid,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-openid";
  version = "1.3.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-J2KLwKN+ZTCUiCMZPgaNeQNa2Ulth7dAQEQ+xITHZXo=";
    pname = "flask_openid";
  };

  # no tests for repo...
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    flask
    python3-openid
  ];

  pyproject = true;

  meta = {
    description = "OpenID support for Flask";
    homepage = "https://pythonhosted.org/Flask-OpenID/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
