{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "semantic-version";
  version = "2.10.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-vau20zaZjLs3jUuds6S1ah4yNXAdwF6iaQ2amX7VBBw=";
    pname = "semantic_version";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "semantic_version" ];

  meta = {
    description = "Library implementing the 'SemVer' scheme";
    homepage = "https://github.com/rbarrois/python-semanticversion/";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      layus
      makefu
    ];
  };
}
