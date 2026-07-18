{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "4.6.12";

  src = fetchFromGitHub {
    owner = "jwillemsen";
    repo = "daikin_onecta";
    tag = "v${version}";
    hash = "sha256-IMYrgSB4Fyc+BEhY4+FGE9Dca7llAQgvkAiOssut04c=";
  };

  domain = "daikin_onecta";
  owner = "jwillemsen";

  meta = {
    description = "Home Assistant Integration for devices supported by the Daikin Onecta App";
    homepage = "https://github.com/jwillemsen/daikin_onecta";
    changelog = "https://github.com/jwillemsen/daikin_onecta/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
