{
  lib,
  buildPythonPackage,
  fetchPypi,
  mesa,
}:

buildPythonPackage rec {
  pname = "pyqt5-sip";
  version = "12.17.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-aC2tzb0iOa+f3AwGKOJ3a4IOEovsiLSbjWkv5oL5C08=";
    pname = "pyqt5_sip";
  };

  # There is no test code and the check phase fails with:
  # > error: could not create 'PyQt5/sip.cpython-38-x86_64-linux-gnu.so': No such file or directory
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "PyQt5.sip" ];

  meta = {
    inherit (mesa.meta) platforms;
    description = "Python bindings for Qt5";
    homepage = "https://github.com/Python-SIP/sip";
    license = lib.licenses.gpl3Only;
  };
}
