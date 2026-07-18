{
  lib,
  buildPythonPackage,
  fetchPypi,
  mock,
  six,
}:
buildPythonPackage rec {
  pname = "hiro";
  version = "1.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2jM5rx3JpZTMqdycccclJysuMGYE5F0OBXXNE8X5XWg=";
  };

  propagatedBuildInputs = [
    six
    mock
  ];

  format = "setuptools";

  meta = {
    description = "Time manipulation utilities for Python";
    homepage = "https://hiro.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nyarly ];
  };
}
