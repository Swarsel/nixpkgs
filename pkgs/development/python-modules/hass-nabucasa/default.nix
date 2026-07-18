{
  lib,
  fetchFromGitHub,
  acme,
  aiohttp,
  atomicwrites-homeassistant,
  attrs,
  buildPythonPackage,
  ciso8601,
  cryptography,
  freezegun,
  grpcio,
  icmplib,
  josepy,
  pycognito,
  pyjwt,
  pytest-aiohttp,
  pytest-socket,
  pytest-timeout,
  pytestCheckHook,
  pythonOlder,
  sentence-stream,
  setuptools,
  snitun,
  syrupy,
  voluptuous,
  webrtc-models,
  xmltodict,
  yarl,
}:

buildPythonPackage (finalAttrs: {
  pname = "hass-nabucasa";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "nabucasa";
    repo = "hass-nabucasa";
    tag = finalAttrs.version;
    hash = "sha256-+HRyXdl/gw/dhZ+T3peinD5FMm0O/M87Uu/wyLU1eJs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "0.0.0" "${finalAttrs.version}"
  '';

  nativeCheckInputs = [
    freezegun
    pytest-aiohttp
    pytest-socket
    pytest-timeout
    pytestCheckHook
    syrupy
    xmltodict
  ];

  build-system = [ setuptools ];

  dependencies = [
    acme
    aiohttp
    atomicwrites-homeassistant
    attrs
    ciso8601
    cryptography
    grpcio
    icmplib
    josepy
    pycognito
    pyjwt
    sentence-stream
    snitun
    voluptuous
    webrtc-models
    yarl
  ];

  disabled = pythonOlder "3.14";
  pyproject = true;
  pythonImportsCheck = [ "hass_nabucasa" ];

  pythonRelaxDeps = [
    "acme"
  ];

  meta = {
    description = "Python module for the Home Assistant cloud integration";
    homepage = "https://github.com/NabuCasa/hass-nabucasa";
    changelog = "https://github.com/NabuCasa/hass-nabucasa/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      fab
      Scriptkiddi
    ];
  };
})
