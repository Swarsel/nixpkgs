{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-six";
  version = "1.17.0.20260518";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-sBltUYi9WJvFq5KQHtwaT/PF/UsNwZ0HSl8fghPlITo=";
    pname = "types_six";
  };

  # Module doesn't have tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "six-stubs"
  ];

  meta = {
    description = "Typing stubs for six";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ YorikSar ];
  };
})
