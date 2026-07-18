{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "unicodecsv";
  version = "0.14.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1z7pdwkr6lpsa7xbyvaly7pq3akflbnz8gq62829lr28gl1hi301";
  };

  # ImportError: No module named runtests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Drop-in replacement for Python2's stdlib csv module, with unicode support";
    homepage = "https://github.com/jdunck/python-unicodecsv";
    license = lib.licenses.bsd2WithViews;
    maintainers = with lib.maintainers; [ koral ];
  };
}
