{
  lib,
  buildPythonPackage,
  fetchPypi,
  ply,
}:

buildPythonPackage rec {
  pname = "cppheaderparser";
  version = "2.7.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-OCswQW2VsKXoUCshSBDcrCpWQykX4mUUR9Or4lPjzEI=";
    pname = "CppHeaderParser";
  };

  propagatedBuildInputs = [ ply ];
  format = "setuptools";
  pythonImportsCheck = [ "CppHeaderParser" ];

  meta = {
    description = "Parse C++ header files using ply.lex to generate navigable class tree representing the class structure";
    homepage = "https://sourceforge.net/projects/cppheaderparser/";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ pamplemousse ];
  };
}
