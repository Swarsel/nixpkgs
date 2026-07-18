{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "timelib";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0bInBlVxhuYFjaiLoPhYN0AbKuneFX9ZNT3JeNglGHo=";
  };

  nativeBuildInputs = [ cython ];
  format = "setuptools";

  meta = {
    description = "Parse english textual date descriptions";
    homepage = "https://github.com/pediapress/timelib/";
    license = lib.licenses.zlib;
  };
}
