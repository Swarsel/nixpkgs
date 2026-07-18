{
  lib,
  fetchFromGitHub,
  aiodns,
  aiohttp,
  aresponses,
  awesomeversion,
  backoff,
  buildPythonPackage,
  cachetools,
  mashumaro,
  orjson,
  poetry-core,
  pycountry,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "radios";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-radios";
    tag = "v${version}";
    hash = "sha256-GXiLwwjZ/pN3HquzLLWq/2EfhmrJyCXq0sovIGRB3uQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    poetry-core
  ];

  dependencies = [
    aiodns
    aiohttp
    awesomeversion
    backoff
    cachetools
    mashumaro
    orjson
    pycountry
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "radios" ];
  pythonRelaxDeps = [ "pycountry" ];

  meta = {
    description = "Asynchronous Python client for the Radio Browser API";
    homepage = "https://github.com/frenck/python-radios";
    changelog = "https://github.com/frenck/python-radios/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
