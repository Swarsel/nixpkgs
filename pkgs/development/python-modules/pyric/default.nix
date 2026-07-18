{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyric";
  version = "0.1.6.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tTmwHK/r0kBsAAl/lFJeoPjs0d2S93MfQ+rA7xbCzMk=";
    pname = "PyRIC";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "__version__ = '0.0.3'" "__version__ = '${version}'"
  '';

  # Tests are outdated
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyric" ];

  meta = {
    description = "Python Radio Interface Controller";
    homepage = "https://github.com/wraith-wireless/PyRIC";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
