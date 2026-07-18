{
  lib,
  buildPythonPackage,
  fetchPypi,
  mypy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "voluptuous-stubs";
  version = "0.1.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-cPscCIJC8g4RAjJStWSM13+DH2ks2RDI+XE8wTXPjMg=";
  };

  nativeBuildInputs = [ mypy ];
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "voluptuous-stubs" ];

  meta = {
    description = "Typing stubs for voluptuous";
    homepage = "https://github.com/ryanwang520/voluptuous-stubs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
