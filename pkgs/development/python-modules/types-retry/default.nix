{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-retry";
  version = "0.9.9.20260408";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-P5j6YuwCdEk4P1wBnM6sx4TB26tHYJid2rQh97hAfZI=";
    pname = "types_retry";
  };

  # Modules doesn't have tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "retry-stubs" ];

  meta = {
    description = "Typing stubs for retry";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
