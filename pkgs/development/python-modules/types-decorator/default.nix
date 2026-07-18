{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-decorator";
  version = "5.2.0.20260519";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-tbI7Lw0RwGdIeAaX00XIpoT8LQx1PwjugGNmDZ16I9k=";
    pname = "types_decorator";
  };

  # Modules doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "decorator-stubs" ];

  meta = {
    description = "Typing stubs for decorator";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
