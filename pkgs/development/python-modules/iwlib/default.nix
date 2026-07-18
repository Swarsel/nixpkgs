{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  pytest,
  wirelesstools,
}:
buildPythonPackage rec {
  pname = "iwlib";
  version = "1.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a805f6597a70ee3001aba8f039fb7b2dcb75dc15c4e7852f5594fd6379196da1";
  };

  nativeBuildInputs = [ pytest ];

  propagatedBuildInputs = [
    wirelesstools
    cffi
  ];

  checkInputs = [ pytest ];
  checkPhase = "python iwlib/_iwlib_build.py; pytest -v";
  format = "setuptools";
  pythonImportsCheck = [ "iwlib" ];

  meta = {
    description = "Python interface for the Wireless Tools utility collection";
    homepage = "https://github.com/nhoad/python-iwlib";
    changelog = "https://github.com/nhoad/python-iwlib#change-history";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jcspeegs ];
  };
}
