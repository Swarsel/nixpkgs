{
  lib,
  aiohttp,
  awesomeversion,
  buildPythonPackage,
  fetchPypi,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "tplink-omada-client";
  version = "1.5.9";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-DjWfz7D29RiMPa7rHm6rdSPI33pAj4JdWwk7EuLEbvk=";
    pname = "tplink_omada_client";
  };

  # Module have no tests
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    awesomeversion
  ];

  pyproject = true;
  pythonImportsCheck = [ "tplink_omada_client" ];

  meta = {
    description = "Library for the TP-Link Omada SDN Controller API";
    homepage = "https://github.com/MarkGodwin/tplink-omada-api";
    changelog = "https://github.com/MarkGodwin/tplink-omada-api/releases/tag/release%2Fv${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "omada";
  };
})
