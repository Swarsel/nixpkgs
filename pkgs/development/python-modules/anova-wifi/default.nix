{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  sensor-state-data,
}:

buildPythonPackage rec {
  pname = "anova-wifi";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "Lash-L";
    repo = "anova_wifi";
    tag = "v${version}";
    hash = "sha256-/9R/41gClcLuJoaJ+CokX9sh4mQryDUsleO+NylU1AE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    sensor-state-data
  ];

  disabledTests = [
    # Makes network calls
    "test_async_data_1"
    # async def functions are not natively supported.
    "test_can_create"
  ];

  pyproject = true;
  pythonImportsCheck = [ "anova_wifi" ];

  meta = {
    description = "Python package for reading anova sous vide api data";
    homepage = "https://github.com/Lash-L/anova_wifi";
    changelog = "https://github.com/Lash-L/anova_wifi/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
