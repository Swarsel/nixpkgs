{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-psycopg2";
  version = "2.9.21.20251012";

  src = fetchPypi {
    inherit version;
    hash = "sha256-TNr9OJJ9oM/eSYBPOauFr9nG6cSSgA5C8fDBobAxKTU=";
    pname = "types_psycopg2";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "psycopg2-stubs" ];

  meta = {
    description = "Typing stubs for psycopg2";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
