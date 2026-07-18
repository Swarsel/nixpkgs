{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "peppercorn";
  version = "0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1ip4bfwcpwkq9hz2dai14k2cyabvwrnvcvrcmzxmqm04g8fnimwn";
  };

  format = "setuptools";

  meta = {
    description = "Library for converting a token stream into a data structure for use in web form posts";
    homepage = "https://docs.pylonsproject.org/projects/peppercorn/en/latest/";
    license = lib.licenses.bsd3Modification;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
