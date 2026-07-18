{
  lib,
  buildPythonPackage,
  fetchPypi,
  sane-backends,
}:

buildPythonPackage rec {
  pname = "sane";
  version = "2.9.1";

  src = fetchPypi {
    inherit version;
    sha256 = "JAmOuDxujhsBEm5q16WwR5wHsBPF0iBQm1VYkv5JJd4=";
    pname = "python-sane";
  };

  buildInputs = [ sane-backends ];
  format = "setuptools";

  meta = {
    description = "Python interface to the SANE scanner and frame grabber";
    homepage = "https://github.com/python-pillow/Sane";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
