{
  lib,
  fetchFromGitHub,
  aiodns,
  aiohttp,
  brotli,
  buildPythonPackage,
  faust-cchardet,
  orjson,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hass-client";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "python-hass-client";
    tag = version;
    hash = "sha256-uCVwxa/KTiOmaexmdeynL2LSqBhDu8Zfre+Nh9Oauiw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "1.0.0" "${version}"
  '';

  # upstream has no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
  ];

  optional-dependencies = {
    speedups = [
      aiodns
      brotli
      faust-cchardet
      orjson
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "hass_client"
  ];

  meta = {
    description = "Basic client for connecting to Home Assistant over websockets and REST";
    homepage = "https://github.com/music-assistant/python-hass-client";
    changelog = "https://github.com/music-assistant/python-hass-client/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
