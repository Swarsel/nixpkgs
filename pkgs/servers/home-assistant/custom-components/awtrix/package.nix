{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  requests,
}:

buildHomeAssistantComponent rec {
  version = "0.3.21";

  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant-custom_components-awtrix";
    # https://github.com/10der/homeassistant-custom_components-awtrix/issues/9
    rev = "8180cef7b1837e85115ef7ece553e39b0f94ff4d";
    hash = "sha256-D/RXi7nX+xqFs5Dvu1pwomQWCJ8PJhc1H3wsAgBhRMQ=";
  };

  dependencies = [
    requests
  ];

  domain = "awtrix";
  owner = "10der";

  meta = {
    description = "Home-assistant integration for awtrix";
    homepage = "https://github.com/10der/homeassistant-custom_components-awtrix";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pinpox ];
  };
}
