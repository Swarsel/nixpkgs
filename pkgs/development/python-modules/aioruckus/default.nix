{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  cryptography,
  hatch-vcs,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "aioruckus";
  version = "0.46.3";

  src = fetchFromGitHub {
    owner = "ms264556";
    repo = "aioruckus";
    tag = "v${version}";
    hash = "sha256-17vcYdggtoeAtGShshseBMB4PSiIOf00nRNIHOAP9Jw=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    aiohttp
    cryptography
    xmltodict
  ];

  disabledTests = [
    # Those tests require a local ruckus device
    "test_ap_info"
    "test_authentication_error"
    "test_connect_success"
    "test_current_active_clients"
    "test_mesh_info"
    "test_system_info"
    # Network access to Ruckus Cloud API
    "test_r1_connect_no_webserver_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioruckus" ];

  meta = {
    description = "Python client for Ruckus Unleashed and Ruckus ZoneDirector";
    homepage = "https://github.com/ms264556/aioruckus";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ fab ];
  };
}
