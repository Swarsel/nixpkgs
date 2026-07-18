{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  isPyPy,
}:

buildPythonPackage rec {
  pname = "random2";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "34ad30aac341039872401595df9ab2c9dc36d0b7c077db1cea9ade430ed1c007";
    extension = "zip";
  };

  patches = [
    # Patch test suite for python >= 3.9
    (fetchpatch {
      sha256 = "064137pg1ilv3f9r10123lqbqz45070jca8pjjyp6gpfd0yk74pi";
      url = "https://github.com/strichter/random2/pull/3/commits/1bac6355d9c65de847cc445d782c466778b94fbd.patch";
    })
  ];

  doCheck = !isPyPy;
  format = "setuptools";

  meta = {
    description = "Python 3 compatible Python 2 `random` Module";
    homepage = "http://pypi.org/pypi/random2/";
    license = lib.licenses.psfl;
  };
}
