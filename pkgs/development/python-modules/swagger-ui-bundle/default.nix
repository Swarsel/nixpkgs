{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  jinja2,
  # build-system
  poetry-core,
}:

buildPythonPackage rec {
  pname = "swagger-ui-bundle";
  version = "1.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-IGc8NDHIcz1dFhXs952azzDP91ICrK8hp9nH9IlxRSk=";
    pname = "swagger_ui_bundle";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ jinja2 ];
  # package contains no tests
  doCheck = false;
  pyproject = true;

  meta = {
    description = "Bundled swagger-ui pip package";
    homepage = "https://github.com/dtkav/swagger_ui_bundle";
    license = lib.licenses.asl20;
  };
}
