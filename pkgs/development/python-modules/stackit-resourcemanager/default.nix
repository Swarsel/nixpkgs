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
  pname = "stackit-resourcemanager";
  version = "0.8.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-9EVCvqtBMIV/Wn9GXPAt7+72V732PBvusxAvC6PAA/4=";
    pname = "stackit_resourcemanager";
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
  pythonImportsCheck = [ "stackit.resourcemanager" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "STACKIT Resource Manager API client for Python";
    homepage = "https://github.com/stackitcloud/stackit-sdk-python";
    changelog = "https://github.com/stackitcloud/stackit-sdk-python/blob/services/resourcemanager/v${finalAttrs.version}/services/resourcemanager/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
