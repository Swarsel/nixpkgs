{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  unixodbc,
}:

buildPythonPackage rec {
  pname = "pyodbc";
  version = "5.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-L+DgY9j7Zu/QrG3DkjbE3hpF8Xwz6t7Q1VPSHBmfTQU=";
  };

  nativeBuildInputs = [
    unixodbc # for odbc_config
  ];

  buildInputs = [ unixodbc ];
  # Tests require a database server
  doCheck = false;
  disabled = isPyPy; # use pypypdbc instead
  format = "setuptools";
  pythonImportsCheck = [ "pyodbc" ];

  meta = {
    description = "Python ODBC module to connect to almost any database";
    homepage = "https://github.com/mkleehammer/pyodbc";
    changelog = "https://github.com/mkleehammer/pyodbc/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.unix;
  };
}
