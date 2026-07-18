{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  yoto-api,
}:

buildHomeAssistantComponent rec {
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "cdnninja";
    repo = "yoto_ha";
    tag = "v${version}";
    hash = "sha256-LaDjT28m5JHIDRcIx9bVy2PNlbEbDANGgdw8fnh+BRU=";
  };

  dependencies = [
    yoto-api
  ];

  domain = "yoto";
  owner = "cdnninja";

  meta = {
    description = "Home Assistant Integration for Yoto";
    homepage = "https://github.com/cdnninja/yoto_ha";
    changelog = "https://github.com/cdnninja/yoto_ha/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seberm ];
  };
}
