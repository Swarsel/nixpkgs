{
  lib,
  buildPythonPackage,
  fetchPypi,
  flask,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-httpauth";
  version = "4.8.0";

  src = fetchPypi {
    hash = "sha256-ZlaKBbxzlCxl8eIgGudGKVgW3ACe3YS0gsRMdY11CXo=";
    pname = "Flask-HTTPAuth";
    version = version;
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ flask ];
  nativeCheckInputs = [ pytestCheckHook ] ++ flask.optional-dependencies.async;
  pyproject = true;
  pythonImportsCheck = [ "flask_httpauth" ];

  meta = {
    description = "Extension that provides HTTP authentication for Flask routes";
    homepage = "https://github.com/miguelgrinberg/Flask-HTTPAuth";
    changelog = "https://github.com/miguelgrinberg/Flask-HTTPAuth/blob/v${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
