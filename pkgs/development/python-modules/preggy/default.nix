{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest8_3CheckHook,
  setuptools,
  six,
  unidecode,
}:

buildPythonPackage rec {
  pname = "preggy";
  version = "1.4.4";

  src = fetchPypi {
    inherit pname version;
    sha256 = "25ba803afde4f35ef543a60915ced2e634926235064df717c3cb3e4e3eb4670c";
  };

  nativeCheckInputs = [ pytest8_3CheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    six
    unidecode
  ];

  pyproject = true;

  meta = {
    description = "Assertion library for Python";
    homepage = "http://heynemann.github.io/preggy/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jluttine ];
  };
}
