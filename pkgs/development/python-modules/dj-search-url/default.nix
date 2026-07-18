{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "dj-search-url";
  version = "0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "424d1a5852500b3c118abfdd0e30b3e0016fe68e7ed27b8553a67afa20d4fb40";
  };

  format = "setuptools";

  meta = {
    description = "Use Search URLs in your Django Haystack Application";
    homepage = "https://github.com/dstufft/dj-search-url";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
