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
  pname = "stackit-iaas";
  version = "1.4.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-k1I7I0QjUMfr79kSlIXEwqU59pSpw2oPjt+rqYYgV+o=";
    pname = "stackit_iaas";
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
  pythonImportsCheck = [ "stackit.iaas" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "STACKIT IaaS API client for Python";
    homepage = "https://github.com/stackitcloud/stackit-sdk-python";
    changelog = "https://github.com/stackitcloud/stackit-sdk-python/blob/services/iaas/v${finalAttrs.version}/services/iaas/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
