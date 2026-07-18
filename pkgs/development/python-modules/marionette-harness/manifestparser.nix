{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "manifestparser";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06cnj682ynacwpi63k1427vbf7ydnwh3dchc4b11yw8ii25wbc5d";
  };

  propagatedBuildInputs = [ ];
  disabled = isPy3k;
  format = "setuptools";

  meta = {
    description = "Mozilla test manifest handling";
    homepage = "https://wiki.mozilla.org/Auto-tools/Projects/Mozbase";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ raskin ];
  };
}
