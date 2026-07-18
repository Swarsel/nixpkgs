{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  awesomeversion,
  buildPythonPackage,
  hatchling,
  mashumaro,
  orjson,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  syrupy,
  webrtc-models,
}:

buildPythonPackage rec {
  pname = "go2rtc-client";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "python-go2rtc-client";
    tag = version;
    hash = "sha256-+/ko59AeFl8R/fRNjB5SykFPXm8PR3s6Imccj/bHkJI=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    syrupy
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    awesomeversion
    mashumaro
    orjson
    webrtc-models
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "go2rtc_client" ];
  pythonRelaxDeps = [ "orjson" ];

  meta = {
    description = "Module for interacting with go2rtc";
    homepage = "https://github.com/home-assistant-libs/python-go2rtc-client";
    changelog = "https://github.com/home-assistant-libs/python-go2rtc-client/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
