{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-mock,
}:

buildPythonPackage rec {
  pname = "flipr-api";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "cnico";
    repo = "flipr-api";
    tag = version;
    hash = "sha256-/px8NuBwukAPMxdXvHdyfO/j/a9UatKbdrjDNuT0f4k=";
  };

  env = {
    FLIPR_PASSWORD = "secret";
    # used in test_session
    FLIPR_USERNAME = "foobar";
  };

  nativeCheckInputs = [
    requests-mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    python-dateutil
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "flipr_api" ];

  meta = {
    description = "Python client for Flipr API";
    homepage = "https://github.com/cnico/flipr-api";
    changelog = "https://github.com/cnico/flipr-api/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "flipr-api";
  };
}
