{
  lib,
  buildPythonPackage,
  fetchPypi,
  pystemmer,
}:

buildPythonPackage (finalAttrs: {
  pname = "snowballstemmer";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "sha256-bV7u7I6fhNTVa4R2krrPebwsjpDH+AykRE/4tvLlKJU=";
  };

  propagatedBuildInputs = [ pystemmer ];
  # No tests included
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "16 stemmer algorithms (15 + Poerter English stemmer) generated from Snowball algorithms";
    homepage = "http://sigal.saimon.org/en/latest/index.html";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
})
