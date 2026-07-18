{
  lib,
  buildPythonPackage,
  fetchPypi,
  networkx,
  numpy,
  pydot,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyformlang";
  version = "1.0.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-4pLsi5z6ZMJrWS+vm3z8csT0sOsNUz8EWkYGHnXFzpk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    networkx
    numpy
    pydot
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyformlang" ];

  meta = {
    description = "Framework for formal grammars";
    homepage = "https://github.com/Aunsiels/pyformlang";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
})
