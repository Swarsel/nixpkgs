{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "visitor";
  version = "0.1.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "02j87v93c50gz68gbgclmbqjcwcr7g7zgvk7c6y4x1mnn81pjwrc";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "visitor" ];

  meta = {
    description = "Tiny pythonic visitor implementation";
    homepage = "https://github.com/mbr/visitor";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
