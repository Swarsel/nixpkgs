{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "i3-py";
  version = "0.6.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1sgl438jrb4cdyl7hbc3ymwsf7y3zy09g1gh7ynilxpllp37jc8y";
  };

  # no tests in tarball
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Tools for i3 users and developers";
    homepage = "https://github.com/ziberna/i3-py";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
  };
}
