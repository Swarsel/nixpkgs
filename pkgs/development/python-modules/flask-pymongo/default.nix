{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  hatchling,
  pymongo,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "flask-pymongo";
  version = "3.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0iW1HCHOyi5nDmzKebXFhK0XuWJStI6E47Qj3bczBMw=";
    pname = "flask_pymongo";
  };

  # requires running MongoDB
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    flask
    pymongo
  ];

  pyproject = true;
  pythonImportsCheck = [ "flask_pymongo" ];

  meta = {
    description = "PyMongo support for Flask applications";
    homepage = "https://github.com/dcrosta/flask-pymongo";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
