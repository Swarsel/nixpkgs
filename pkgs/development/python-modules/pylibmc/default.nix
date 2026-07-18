{
  lib,
  buildPythonPackage,
  cyrus_sasl,
  fetchPypi,
  libmemcached,
  zlib,
}:

buildPythonPackage rec {
  pname = "pylibmc";
  version = "1.6.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7vpGEVU3q61l++LgMqzRs0Y9m/njNa9LCRbfTk0yBuA=";
  };

  buildInputs = [
    cyrus_sasl
    libmemcached
    zlib
  ];

  # Requires an external memcached server running
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pylibmc" ];
  setupPyBuildFlags = [ "--with-sasl2" ];

  meta = {
    description = "Quick and small memcached client for Python";
    homepage = "http://sendapatch.se/projects/pylibmc/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
