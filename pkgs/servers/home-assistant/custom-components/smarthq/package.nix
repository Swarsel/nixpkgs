{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "geappliances";
    repo = "geappliances-smarthq-integration";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PwCorYIqRK4gQLaYxoebIVRIeTcIrDo3CRNs/6DUc9o=";
  };

  dependencies = [
    aiohttp
  ];

  domain = "smarthq";
  owner = "geappliances";

  meta = {
    description = "Home Assistant integration for GE Appliances SmartHQ connected devices";
    homepage = "https://github.com/geappliances/geappliances-smarthq-integration";
    changelog = "https://github.com/geappliances/geappliances-smarthq-integration/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
