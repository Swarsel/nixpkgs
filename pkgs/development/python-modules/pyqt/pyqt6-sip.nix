{
  lib,
  buildPythonPackage,
  fetchPypi,
  mesa,
}:

buildPythonPackage rec {
  pname = "pyqt6-sip";
  version = "13.10.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RkrRVr9SZQDOa9BcrHqCKAr2MJl02BZzm0qaYnFW+v4=";
    pname = "pyqt6_sip";
  };

  # There is no test code and the check phase fails with:
  # > error: could not create 'PyQt5/sip.cpython-38-x86_64-linux-gnu.so': No such file or directory
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "PyQt6.sip" ];

  meta = {
    inherit (mesa.meta) platforms;
    description = "Python bindings for Qt5";
    homepage = "https://github.com/Python-SIP/sip";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ LunNova ];
  };
}
