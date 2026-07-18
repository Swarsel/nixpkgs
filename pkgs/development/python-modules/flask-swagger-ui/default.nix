{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
}:

buildPythonPackage rec {
  pname = "flask-swagger-ui";
  version = "5.21.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-hy0DjcEaaOrKuI9vBb48UzqjAEU+Jzd12tPgKbMeA9Q=";
    pname = "flask_swagger_ui";
  };

  propagatedBuildInputs = [ flask ];
  doCheck = false; # there are no tests
  format = "setuptools";

  meta = {
    description = "Swagger UI blueprint for Flask";
    homepage = "https://github.com/sveint/flask-swagger-ui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vanschelven ];
  };
}
