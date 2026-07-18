{
  lib,
  aiohttp,
  aioresponses,
  async-timeout,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "foobot-async";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-QQjysk2m8QkOpLBdC8kfuoA9PcljgEwzKyrIAhxHB4c=";
    pname = "foobot_async";
  };

  postPatch = ''
    # https://github.com/reefab/foobot_async/issues/7
    substituteInPlace foobot_async/__init__.py \
      --replace-fail "with async_timeout.timeout" "async with async_timeout.timeout"
  '';

  nativeCheckInputs = [
    aioresponses
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
  ];

  pyproject = true;
  pythonImportsCheck = [ "foobot_async" ];

  meta = {
    description = "API Client for Foobot Air Quality Monitoring devices";
    homepage = "https://github.com/reefab/foobot_async";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
