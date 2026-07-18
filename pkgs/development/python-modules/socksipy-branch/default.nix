{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "socksipy-branch";
  version = "1.01";

  src = fetchPypi {
    inherit version;
    sha256 = "01l41v4g7fy9fzvinmjxy6zcbhgqaif8dhdqm4w90fwcw9h51a8p";
    pname = "SocksiPy-branch";
  };

  format = "setuptools";

  meta = {
    description = "This Python module allows you to create TCP connections through a SOCKS proxy without any special effort";
    homepage = "http://code.google.com/p/socksipy-branch/";
    license = lib.licenses.bsd3;
  };
}
