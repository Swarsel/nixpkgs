{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyparsing,
}:
buildPythonPackage (finalAttrs: {
  pname = "pylibconfig2";
  version = "0.2.5";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "1iwm11v0ghv2pq2cyvly7gdwrhxsx6iwi581fz46l0snhgcd4sqq";
  };

  propagatedBuildInputs = [ pyparsing ];
  # tests not included in the distribution
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Pure python library for libconfig syntax";
    homepage = "https://github.com/heinzK1X/pylibconfig2";
    license = lib.licenses.gpl3;
  };
})
