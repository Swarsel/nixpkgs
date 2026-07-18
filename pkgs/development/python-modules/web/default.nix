{
  lib,
  buildPythonPackage,
  cheroot,
  dbutils,
  fetchPypi,
  legacy-cgi,
  mysql-connector-python,
  mysqlclient,
  psycopg2,
  pymysql,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "web.py";
  version = "0.62";

  src = fetchPypi {
    inherit pname version;
    sha256 = "5ce684caa240654cae5950da8b4b7bc178812031e08f990518d072bd44ab525e";
  };

  propagatedBuildInputs = [
    cheroot
    legacy-cgi
  ];

  # requires multiple running databases
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    dbutils
    mysqlclient
    pymysql
    mysql-connector-python
    psycopg2
  ];

  format = "setuptools";
  pythonImportsCheck = [ "web" ];

  meta = {
    description = "Makes web apps";

    longDescription = ''
      Think about the ideal way to write a web app.
      Write the code to make it happen.
    '';

    homepage = "https://webpy.org/";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ layus ];
  };
}
