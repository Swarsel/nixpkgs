{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "types-awscrt";
  version = "0.34.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-VZqgQlD2pBmmF9+3iPPhCQOq90cA7yPlIbZKQRuDuAM=";
    pname = "types_awscrt";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "awscrt-stubs" ];

  meta = {
    description = "Type annotations and code completion for awscrt";
    homepage = "https://github.com/youtype/types-awscrt";
    changelog = "https://github.com/youtype/types-awscrt/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
