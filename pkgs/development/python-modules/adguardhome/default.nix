{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "adguardhome";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-${pname}";
    tag = "v${version}";
    hash = "sha256-pc7UfR/0mQZ98FyomQErz5hePHy6KE2h9UhJ9lFGtFA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"0.0.0"' '"${version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "adguardhome" ];

  meta = {
    description = "Python client for the AdGuard Home API";
    homepage = "https://github.com/frenck/python-adguardhome";
    changelog = "https://github.com/frenck/python-adguardhome/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
