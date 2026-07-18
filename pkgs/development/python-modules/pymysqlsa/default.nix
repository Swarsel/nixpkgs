{
  lib,
  buildPythonPackage,
  fetchPypi,
  pymysql,
  sqlalchemy,
}:

buildPythonPackage rec {
  pname = "pymysql-sa";
  version = "1.0";

  src = fetchPypi {
    inherit version;
    sha256 = "a2676bce514a29b2d6ab418812259b0c2f7564150ac53455420a20bd7935314a";
    pname = "pymysql_sa";
  };

  propagatedBuildInputs = [
    pymysql
    sqlalchemy
  ];

  format = "setuptools";

  meta = {
    description = "PyMySQL dialect for SQL Alchemy";
    homepage = "https://pypi.org/project/pymysql_sa/";
    license = lib.licenses.mit;
  };
}
