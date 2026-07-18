{
  lib,
  buildPythonPackage,
  cssselect,
  fetchPypi,
  lxml,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "leather";
  version = "0.4.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ZxGcKu6TvoIfB3GTvYU04pbAWzi9F02cWoDEqjHRpNM=";
  };

  propagatedBuildInputs = [ six ];

  nativeCheckInputs = [
    cssselect
    lxml
    pytestCheckHook
  ];

  format = "setuptools";

  meta = {
    description = "Python charting library";
    homepage = "http://leather.rtfd.io";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
