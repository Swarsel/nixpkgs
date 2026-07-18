{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest,
  six,
}:

buildPythonPackage rec {
  pname = "latexcodec";
  version = "3.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-54ppEc1y+d7DUDHG7CNYTeaEK/vEYQqWeIaNFM37A1c=";
  };

  propagatedBuildInputs = [ six ];
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    pytest
  '';

  format = "setuptools";

  meta = {
    description = "Lexer and codec to work with LaTeX code in Python";
    homepage = "https://github.com/mcmtroffaes/latexcodec";
    license = lib.licenses.mit;
  };
}
