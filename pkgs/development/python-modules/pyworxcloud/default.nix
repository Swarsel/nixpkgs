{
  lib,
  fetchFromGitHub,
  aiohttp,
  awsiotsdk,
  buildPythonPackage,
  paho-mqtt,
  poetry-core,
  requests,
  tzdata,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyworxcloud";
  version = "6.4.1";

  src = fetchFromGitHub {
    owner = "MTrab";
    repo = "pyworxcloud";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ouyR0BNUqu8ywSfzfjd3oIXPxVHcyXumFYthsPk+4i4=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    awsiotsdk
    paho-mqtt
    requests
    urllib3
    tzdata
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyworxcloud" ];
  pythonRelaxDeps = [ "awsiotsdk" ];

  meta = {
    description = "Module for integrating with Worx Cloud devices";
    homepage = "https://github.com/MTrab/pyworxcloud";
    changelog = "https://github.com/MTrab/pyworxcloud/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      gpl3Only
      mit
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
})
