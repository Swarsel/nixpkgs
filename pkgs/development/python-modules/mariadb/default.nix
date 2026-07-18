{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libmysqlclient,
  packaging,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mariadb";
  version = "1.1.14";

  src = fetchFromGitHub {
    owner = "mariadb-corporation";
    repo = "mariadb-connector-python";
    tag = "v${version}";
    hash = "sha256-BPyEBQ5M/kqTKpZX/incgTX/+E1dMZW98GuywsBeCJw=";
  };

  nativeBuildInputs = [
    libmysqlclient # for mariadb_config
  ];

  buildInputs = [ libmysqlclient ];
  # Requires a running MariaDB instance
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    packaging # do not rely on pythonImportsCheck when removing, it pulls in build-system dependencies
  ];

  pyproject = true;
  pythonImportsCheck = [ "mariadb" ];

  meta = {
    description = "MariaDB Connector/Python";
    homepage = "https://github.com/mariadb-corporation/mariadb-connector-python";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
