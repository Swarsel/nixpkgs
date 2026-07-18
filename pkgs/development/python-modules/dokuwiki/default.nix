{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "dokuwiki";
  version = "1.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gtTyO6jmjQT0ZwmxvH+RAe1v5aruNStfP1qz1+AqYXs=";
  };

  format = "setuptools";
  pythonImportsCheck = [ "dokuwiki" ];

  meta = {
    description = "Python module that aims to manage DokuWiki wikis by using the provided XML-RPC API";
    homepage = "https://github.com/fmenabe/python-dokuwiki";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ netali ];
  };
}
