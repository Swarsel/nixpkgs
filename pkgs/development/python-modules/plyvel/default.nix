{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  pkgs,
  pytest,
}:

buildPythonPackage rec {
  pname = "plyvel";
  version = "1.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-PK9gCeT8JPv4cS0/XvPaflZJXCakiN8hYSGPw05GAZw=";
  };

  buildInputs = [ pkgs.leveldb ] ++ lib.optional isPy3k pytest;
  # no tests for python2
  doCheck = isPy3k;
  format = "setuptools";

  meta = {
    description = "Fast and feature-rich Python interface to LevelDB";
    homepage = "https://github.com/wbolster/plyvel";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
}
