{
  lib,
  buildPythonPackage,
  numpy,
  pkgs,
  pybind11,
}:

buildPythonPackage {
  inherit (pkgs.fasttext) pname version src;
  buildInputs = [ pybind11 ];
  propagatedBuildInputs = [ numpy ];

  preBuild = ''
    HOME=$TMPDIR
  '';

  format = "setuptools";
  pythonImportsCheck = [ "fasttext" ];

  meta = {
    description = "Python module for text classification and representation learning";
    homepage = "https://fasttext.cc/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
