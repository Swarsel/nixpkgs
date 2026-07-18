{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pymysql";
  version = "1.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-SWHT4WVhSuZQFONhgRpyTiBErT6jc53pkDrnwh9TnwM=";
    pname = "pymysql";
  };

  propagatedBuildInputs = [ cryptography ];
  # Wants to connect to MySQL
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Pure Python MySQL Client";
    homepage = "https://github.com/PyMySQL/PyMySQL";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kalbasit ];
  };
}
