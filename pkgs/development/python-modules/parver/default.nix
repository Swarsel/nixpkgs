{
  lib,
  arpeggio,
  attrs,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pretend,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "parver";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uf3h5ruc6fB+COnEvqjYglxeeOGKAFLQLgK/lRfrR3c=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    attrs
    arpeggio
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    pretend
  ];

  pyproject = true;

  meta = {
    description = "Allows parsing and manipulation of PEP 440 version numbers";
    homepage = "https://github.com/RazerM/parver";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
