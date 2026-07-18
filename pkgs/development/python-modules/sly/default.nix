{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sly";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JR1CAV6FBxWK7CFk8GA130qCsDFM5kUPRX1xJedkkCQ=";
  };

  postPatch = ''
    # imperative dev dependency installation
    rm Makefile
  '';

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "sly" ];

  meta = {
    description = "Improved PLY implementation of lex and yacc for Python 3";
    homepage = "https://github.com/dabeaz/sly";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
