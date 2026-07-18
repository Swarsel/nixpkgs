{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-pytz";
  version = "2026.1.1.20260304";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-DDVC2OmwFgtCQjNEDFK4PW9YyuS4UzPVTk+WHPAT4Rc=";
    pname = "types_pytz";
  };

  # Modules doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pytz-stubs" ];

  meta = {
    description = "Typing stubs for pytz";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
