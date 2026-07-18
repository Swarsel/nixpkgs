{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyhumps,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "complycube";
  version = "1.1.8";

  src = fetchPypi {
    inherit version;
    hash = "sha256-lN8J9QQ9YvclYzuXtck+lt1IgS5McOE1YU0NLl9rW0I=";
    pname = "complycube";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    pyhumps
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "complycube" ];

  meta = {
    description = "Official Python client for the ComplyCube API";
    homepage = "https://complycube.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
