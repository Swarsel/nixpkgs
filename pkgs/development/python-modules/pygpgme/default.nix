{
  lib,
  fetchurl,
  buildPythonPackage,
  gpg,
  isPyPy,
  pythonAtLeast,
}:

buildPythonPackage rec {
  pname = "pygpgme";
  version = "0.3";

  src = fetchurl {
    url = "https://launchpad.net/pygpgme/trunk/${version}/+download/${pname}-${version}.tar.gz";
    sha256 = "5fd887c407015296a8fd3f4b867fe0fcca3179de97ccde90449853a3dfb802e1";
  };

  propagatedBuildInputs = [ gpg ];
  # error: invalid command 'test'
  doCheck = false;
  # Native code doesn't compile against the C API of Python 3.11:
  # https://bugs.launchpad.net/pygpgme/+bug/1996122
  disabled = isPyPy || pythonAtLeast "3.11";
  format = "setuptools";

  meta = {
    description = "Python wrapper for the GPGME library";
    homepage = "https://launchpad.net/pygpgme";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
  };
}
