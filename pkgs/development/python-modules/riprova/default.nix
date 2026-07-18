{
  lib,
  buildPythonPackage,
  fetchPypi,
  six,
}:

buildPythonPackage rec {
  pname = "riprova";
  version = "0.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FgFySbvBjcZU2bjo40/1O7glc6oFWW05jinEOfMWMVI=";
  };

  propagatedBuildInputs = [ six ];
  # PyPI archive doesn't have tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "riprova" ];

  meta = {
    description = "Small and versatile library to retry failed operations using different backoff strategies";
    homepage = "https://github.com/h2non/riprova";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mmilata ];
  };
}
