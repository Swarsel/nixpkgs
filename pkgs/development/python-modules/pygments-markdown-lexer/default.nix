{
  lib,
  buildPythonPackage,
  fetchPypi,
  pygments,
}:

buildPythonPackage rec {
  pname = "pygments-markdown-lexer";
  version = "0.1.0.dev39";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1pzb5wy23q3fhs0rqzasjnw6hdzwjngpakb73i98cn0b8lk8q4jc";
    extension = "zip";
  };

  propagatedBuildInputs = [ pygments ];
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Pygments Markdown Lexer – A Markdown lexer for Pygments to highlight Markdown code snippets";
    homepage = "https://github.com/jhermann/pygments-markdown-lexer";
    license = lib.licenses.asl20;
  };
}
