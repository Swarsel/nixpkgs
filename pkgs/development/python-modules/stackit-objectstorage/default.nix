{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  nix-update-script,
  pydantic,
  python-dateutil,
  requests,
  stackit-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "stackit-objectstorage";
  version = "1.4.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-SjgStN4QKxmfBhcGqAKQn55TrpsIWHadW9cg+BTIvb4=";
    pname = "stackit_objectstorage";
  };

  # Module has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    pydantic
    python-dateutil
    requests
    stackit-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "stackit.objectstorage" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "STACKIT Object Storage API client for Python";
    homepage = "https://github.com/stackitcloud/stackit-sdk-python";
    changelog = "https://github.com/stackitcloud/stackit-sdk-python/blob/services/objectstorage/v${finalAttrs.version}/services/objectstorage/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
