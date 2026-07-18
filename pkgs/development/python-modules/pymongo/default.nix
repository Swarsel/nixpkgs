{
  lib,
  buildPythonPackage,
  # for passthru.tests
  celery, # check-input only
  dnspython,
  fetchPypi,
  flask-pymongo,
  hatch-requirements-txt,
  hatchling,
  kombu, # check-input only
  mongoengine,
  motor,
  pymongo-inmemory,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymongo";
  version = "4.16.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-i6hAUGX24lim+HL+YteXoo84OhIXjHFTwB7QToRcYAw=";
    pname = "pymongo";
  };

  # Tests call a running mongodb instance
  doCheck = false;

  build-system = [
    hatchling
    hatch-requirements-txt
    setuptools
  ];

  dependencies = [ dnspython ];
  pyproject = true;
  pythonImportsCheck = [ "pymongo" ];

  passthru.tests = {
    inherit
      celery
      flask-pymongo
      kombu
      mongoengine
      motor
      pymongo-inmemory
      ;
  };

  meta = {
    description = "Python driver for MongoDB";
    homepage = "https://github.com/mongodb/mongo-python-driver";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
