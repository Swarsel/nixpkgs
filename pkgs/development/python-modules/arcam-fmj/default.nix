{
  lib,
  fetchFromGitHub,
  aiohttp,
  attrs,
  buildPythonPackage,
  defusedxml,
  pytest-aiohttp,
  pytest-asyncio_0,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "arcam-fmj";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "elupus";
    repo = "arcam_fmj";
    tag = version;
    hash = "sha256-Oa/uCktLITzh3ZNW8RSCt6lYax0VmbAGW+coGnoiTpo=";
  };

  nativeCheckInputs = [
    pytest-asyncio_0
    pytest-aiohttp
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    attrs
    defusedxml
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.12") [
    # stuck on EpollSelector.poll()
    "test_power"
    "test_multiple"
    "test_invalid_command"
    "test_state"
    "test_silent_server_request"
    "test_silent_server_disconnect"
    "test_heartbeat"
    "test_cancellation"
    "test_unsupported_zone"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "arcam.fmj"
    "arcam.fmj.client"
    "arcam.fmj.state"
    "arcam.fmj.utils"
  ];

  meta = {
    description = "Python library for speaking to Arcam receivers";
    homepage = "https://github.com/elupus/arcam_fmj";
    changelog = "https://github.com/elupus/arcam_fmj/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "arcam-fmj";
  };
}
