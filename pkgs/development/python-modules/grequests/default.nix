{
  lib,
  buildPythonPackage,
  fetchPypi,
  gevent,
  requests,
}:

buildPythonPackage rec {
  pname = "grequests";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-XDPxQmjfW4+hEH2FN4Fb5v67rW7FYFJNakBLd3jPa6Y=";
  };

  propagatedBuildInputs = [
    requests
    gevent
  ];

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Asynchronous HTTP requests";
    homepage = "https://github.com/kennethreitz/grequests";
    license = with lib.licenses; [ bsd2 ];
    maintainers = with lib.maintainers; [ matejc ];
  };
}
