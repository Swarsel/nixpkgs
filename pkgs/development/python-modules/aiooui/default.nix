{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aiooui";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "Bluetooth-Devices";
    repo = "aiooui";
    tag = "v${version}";
    hash = "sha256-tY8/hb3BpxzKM/IB7anfmqGcXK6FmiuoJVxqpFW1Maw=";
  };

  postPatch = ''
    # Remove requirements and build part for the OUI data
    substituteInPlace pyproject.toml \
      --replace-fail 'script = "build_oui.py"' "" \
      --replace-fail ", 'requests', 'aiohttp'" "" \
      --replace-fail '"setuptools>=65.4.1", ' ""
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "aiooui" ];

  meta = {
    description = "Async OUI lookups";
    homepage = "https://github.com/Bluetooth-Devices/aiooui";
    changelog = "https://github.com/Bluetooth-Devices/aiooui/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
