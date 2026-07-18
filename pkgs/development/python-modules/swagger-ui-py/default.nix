{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  jinja2,
  packaging,
  pyyaml,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "swagger-ui-py";
  version = "25.7.1";

  src = fetchFromGitHub {
    owner = "PWZER";
    repo = "swagger-ui-py";
    tag = "v${version}";
    hash = "sha256-yPGt7EG8KvGoI7Unz0E7fn7nG9Ei/h8Q3TDKnuVVRkQ=";
  };

  env.VERSION = version;
  doCheck = false; # huge dependency closure on all sorts of web frameworks, http clients, etc.

  build-system = [
    setuptools
  ];

  dependencies = [
    jinja2
    packaging
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "swagger_ui"
  ];

  meta = {
    description = "Swagger UI for Python web framework, such Tornado, Flask and Sanic. https://pwzer.github.io/swagger-ui-py";
    homepage = "https://github.com/PWZER/swagger-ui-py";
    changelog = "https://github.com/PWZER/swagger-ui-py/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
