{
  lib,
  buildPythonPackage,
  fetchPypi,
  minikerberos,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "winsspi";
  version = "0.0.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-AXC6SJ+iWPGqTmdgoWKEbD8tDUUcg2aD609hO2bdQfM=";
  };

  # Module doesn't have tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ minikerberos ];
  pyproject = true;
  pythonImportsCheck = [ "winsspi" ];

  meta = {
    description = "Python module for ACL/ACE/Security descriptor manipulation";
    homepage = "https://github.com/skelsec/winsspi";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
