{
  lib,
  azure-common,
  azure-mgmt-core,
  buildPythonPackage,
  fetchPypi,
  isodate,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "azure-mgmt-redis";
  version = "14.5.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-XDQ0yCSSaI4luTqvURPs/wuSt61toqT9RpVTD4KxUvo=";
    pname = "azure_mgmt_redis";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    isodate
    azure-common
    azure-mgmt-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "azure.mgmt.redis" ];

  meta = {
    description = "This is the Microsoft Azure Redis Cache Management Client Library";
    homepage = "https://github.com/Azure/azure-sdk-for-python";
    changelog = "https://github.com/Azure/azure-sdk-for-python/blob/azure-mgmt-redis_${finalAttrs.version}/sdk/redis/azure-mgmt-redis/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ maxwilson ];
  };
})
