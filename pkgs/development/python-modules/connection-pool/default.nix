{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "connection-pool";
  version = "0.0.3";

  src = fetchPypi {
    inherit version;
    sha256 = "bf429e7aef65921c69b4ed48f3d48d3eac1383b05d2df91884705842d974d0dc";
    pname = "connection_pool";
  };

  doCheck = false; # no tests
  disabled = !isPy3k;
  format = "setuptools";
  pythonImportsCheck = [ "connection_pool" ];

  meta = {
    description = "Thread-safe connection pool";
    homepage = "https://github.com/zhouyl/ConnectionPool";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
