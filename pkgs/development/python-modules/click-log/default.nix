{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "click-log";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OXD4VwrFRJEje82z2KtePu9sBX3yn4w9EVGlGpwjuXU=";
  };

  propagatedBuildInputs = [ click ];
  format = "setuptools";

  meta = {
    description = "Logging integration for Click";
    homepage = "https://github.com/click-contrib/click-log/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
