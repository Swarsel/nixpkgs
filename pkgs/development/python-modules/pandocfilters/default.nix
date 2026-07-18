{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pandocfilters";
  version = "1.5.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ACtKVV7k68A/i2Ywfih/pJLkp3tOoU0/k0MoKXu0k54=";
  };

  # No tests available
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Python module for writing pandoc filters, with a collection of examples";
    homepage = "https://github.com/jgm/pandocfilters";
    license = lib.licenses.mit;
  };
}
