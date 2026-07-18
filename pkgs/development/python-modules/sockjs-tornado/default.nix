{
  lib,
  buildPythonPackage,
  fetchPypi,
  tornado,
}:

buildPythonPackage rec {
  pname = "sockjs-tornado";
  version = "1.0.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02ff25466b3a46b1a7dbe477340b042770ac078de7ea475a6285a28a75eb1fab";
  };

  propagatedBuildInputs = [ tornado ];
  format = "setuptools";

  meta = {
    description = "SockJS python server implementation on top of Tornado framework";
    homepage = "https://github.com/mrjoes/sockjs-tornado/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
