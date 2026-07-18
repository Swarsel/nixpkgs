{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "types-openpyxl";
  version = "3.1.5.20260518";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-2pzWROToAhWj9gqMLCyOmA6UGptYHP+jh2KFqnkcpa8=";
    pname = "types_openpyxl";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "openpyxl-stubs" ];

  meta = {
    description = "Typing stubs for openpyxl";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.me-and ];
  };
})
