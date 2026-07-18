{
  lib,
  # optional-dependencies
  asgiref,
  # dependencies
  blinker,
  buildPythonPackage,
  click,
  fetchPypi,
  # reverse dependencies
  flask-limiter,
  flask-restful,
  flask-restx,
  # build-system
  flit-core,
  itsdangerous,
  jinja2,
  moto,
  # tests
  pytestCheckHook,
  python-dotenv,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "flask";
  version = "3.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-v2VsFcgBkO1iitCM39Oqo1vrCHhV4vSUkQqjd0zE/Yc=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ lib.concatAttrValues optional-dependencies;
  build-system = [ flit-core ];

  dependencies = [
    click
    blinker
    itsdangerous
    jinja2
    werkzeug
  ];

  optional-dependencies = {
    async = [ asgiref ];
    dotenv = [ python-dotenv ];
  };

  pyproject = true;

  passthru.tests = {
    inherit
      flask-limiter
      flask-restful
      flask-restx
      moto
      ;
  };

  meta = {
    description = "Python micro framework for building web applications";

    longDescription = ''
      Flask is a lightweight WSGI web application framework. It is
      designed to make getting started quick and easy, with the ability
      to scale up to complex applications. It began as a simple wrapper
      around Werkzeug and Jinja and has become one of the most popular
      Python web application frameworks.
    '';

    homepage = "https://flask.palletsprojects.com/";

    changelog = "https://flask.palletsprojects.com/en/stable/changes/#version-${
      lib.replaceStrings [ "." ] [ "-" ] version
    }";

    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "flask";
  };
}
