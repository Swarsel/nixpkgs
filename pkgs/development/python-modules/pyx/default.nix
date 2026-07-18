{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "pyx";
  version = "0.17";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-O8iqgJExVZ96XA4fESm0LHGt423wMyET9cV3k4SjmvE=";
  };

  # No tests in archive
  doCheck = false;
  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Python package for the generation of PostScript, PDF, and SVG files";
    homepage = "https://pyx.sourceforge.net/";
    license = with lib.licenses; [ gpl2 ];
  };
}
