{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "sslib";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0b5zrjkvx4klmv57pzhcmvbkdlyn745mn02k7hp811hvjrhbz417";
  };

  # No tests available
  doCheck = false;
  disabled = !isPy3k;
  format = "setuptools";

  meta = {
    description = "Python3 library for sharing secrets";
    homepage = "https://github.com/jqueiroz/python-sslib";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jqueiroz ];
  };
}
