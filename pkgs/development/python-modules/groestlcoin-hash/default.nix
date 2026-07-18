{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "groestlcoin-hash";
  version = "1.0.3";

  src = fetchPypi {
    inherit version;
    sha256 = "31a8f6fa4c19db5258c3c73c071b71702102c815ba862b6015d9e4b75ece231e";
    pname = "groestlcoin_hash";
  };

  format = "setuptools";
  pythonImportsCheck = [ "groestlcoin_hash" ];

  meta = {
    description = "Bindings for groestl key derivation function library used in Groestlcoin";
    homepage = "https://pypi.org/project/groestlcoin_hash/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gruve-p ];
  };
}
