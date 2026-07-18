{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  poetry-core,
  pytest-aiohttp,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "aiohttp-middlewares";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "playpauseandstop";
    repo = "aiohttp-middlewares";
    tag = "v${version}";
    hash = "sha256-jUH1XhkytRwR76wUTsGQGu6m8s+SZ/GO114Lz9atwE8=";
  };

  postPatch = ''
    sed -i "/addopts/d" pyproject.toml
  '';

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    async-timeout
    yarl
  ];

  disabledTests = [
    # TRests are outdated
    "test_shield_middleware_funcitonal[DELETE-False]"
    "test_shield_middleware_funcitonal[GET-False]"
    "test_shield_middleware_funcitonal[POST-True]"
    "test_shield_middleware_funcitonal[PUT-False]"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohttp_middlewares" ];
  pythonRelaxDeps = [ "async-timeout" ];

  meta = {
    description = "Collection of useful middlewares for aiohttp.web applications";
    homepage = "https://github.com/playpauseandstop/aiohttp-middlewares";
    changelog = "https://github.com/playpauseandstop/aiohttp-middlewares/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
