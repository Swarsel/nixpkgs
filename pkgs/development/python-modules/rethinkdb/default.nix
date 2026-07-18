{
  lib,
  buildPythonPackage,
  fetchPypi,
  looseversion,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "rethinkdb";
  version = "2.4.10.post1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NjTgPuE91jf9cZa4BHS/RMZNProd0GnqkrlJJnAqYL0=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    looseversion
    six
  ];

  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "rethinkdb" ];

  meta = {
    description = "Python driver library for the RethinkDB database server";
    homepage = "https://github.com/RethinkDB/rethinkdb-python";
    license = lib.licenses.asl20;
  };
}
