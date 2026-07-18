{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildHomeAssistantComponent,
  casttube,
  wakeonlan,
  websocket-client,
}:

buildHomeAssistantComponent rec {
  version = "0.14.5";

  src = fetchFromGitHub {
    owner = "ollo69";
    repo = "ha-samsungtv-smart";
    tag = "v${version}";
    hash = "sha256-J3+HD/jMJDIBSiVJnHvjOJ3yswck+DV3XpPqIoR5/sU=";
  };

  dependencies = [
    aiofiles
    casttube
    websocket-client
    wakeonlan
  ];

  domain = "samsungtv_smart";
  owner = "ollo69";

  meta = {
    description = "Home Assistant Samsung TV Integration";
    homepage = "https://github.com/ollo69/ha-samsungtv-smart";
    changelog = "https://github.com/ollo69/ha-samsungtv-smart/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mindstorms6 ];
  };
}
