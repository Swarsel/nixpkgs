{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-sslify";
  version = "0.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0z4dPAnNlRVBdqqKcxlBjlISn8SC3VbYqK18JFANVD4=";
    pname = "Flask-SSLify";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ flask ];
  pyproject = true;
  pythonImportsCheck = [ "flask_sslify" ];

  meta = {
    description = "Flask extension that redirects all incoming requests to HTTPS";
    homepage = "https://github.com/kennethreitz42/flask-sslify";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
}
