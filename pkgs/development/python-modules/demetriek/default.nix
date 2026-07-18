{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  awesomeversion,
  backoff,
  buildPythonPackage,
  mashumaro,
  orjson,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  syrupy,
  yarl,
}:

buildPythonPackage rec {
  pname = "demetriek";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "frenck";
    repo = "python-demetriek";
    tag = "v${version}";
    hash = "sha256-6vzQaifvQ24LpSQFwPMvEvb1wuyv0iRpLCFHFO9V7sc=";
  };

  postPatch = ''
    # Upstream doesn't set a version for the pyproject.toml
    substituteInPlace pyproject.toml \
      --replace-fail "0.0.0" "${version}"
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    awesomeversion
    backoff
    mashumaro
    orjson
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "demetriek" ];

  meta = {
    description = "Python client for LaMetric TIME devices";
    homepage = "https://github.com/frenck/python-demetriek";
    changelog = "https://github.com/frenck/python-demetriek/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
