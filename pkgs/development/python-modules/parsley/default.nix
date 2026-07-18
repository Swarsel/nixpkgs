{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "parsley";
  version = "1.3";

  src = fetchPypi {
    inherit version;
    sha256 = "0hcd41bl07a8sx7nmx12p16xprnblc4phxkawwmmy78n8y6jfi4l";
    pname = "Parsley";
  };

  # Tests fail although the package works just fine.  Unfortunately
  # the tests as run by the upstream CI server travis.org are broken.
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Parser generator library based on OMeta, and other useful parsing tools";
    homepage = "https://launchpad.net/parsley";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seppeljordan ];
  };
}
