{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "py-sonic";
  version = "1.0.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Kcly3pTBL9ZMDcCfKgI1pO8Iyr15/tv8PVoi5WUUUKE=";
  };

  # package has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "libsonic" ];

  meta = {
    description = "Python wrapper library for the Subsonic REST API";
    homepage = "https://github.com/crustymonkey/py-sonic";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ wenngle ];
  };
}
