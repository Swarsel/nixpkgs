{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  # tests
  mock,
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  pytz,
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyindego";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "sander1988";
    repo = "pyIndego";
    tag = version;
    hash = "sha256-x8/MSbn+urmArQCyxZU1JEUyATJsPzp7bflymE+1rkk=";
  };

  postPatch = ''
    sed -i "/addopts/d" pytest.ini
  '';

  nativeCheckInputs = [
    mock
    pytest-aiohttp
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
    pytz
  ];

  disabledTests = [
    # Typeerror, presumably outdated tests
    "test_repr"
    "test_client_response_errors"
    "test_update_battery"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyIndego" ];

  meta = {
    description = "Python interface for Bosch API for lawnmowers";
    homepage = "https://github.com/sander1988/pyIndego";
    changelog = "https://github.com/sander1988/pyIndego/blob/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
