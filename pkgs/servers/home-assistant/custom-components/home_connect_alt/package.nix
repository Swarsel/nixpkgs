{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-connect-async,
}:

buildHomeAssistantComponent rec {
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "ekutner";
    repo = "home-connect-hass";
    tag = version;
    hash = "sha256-B8FQBvxHhTCSCnq40QiZKU+OnN9knzeUedpEmI04uss=";
  };

  dependencies = [ home-connect-async ];
  domain = "home_connect_alt";
  owner = "ekutner";

  meta = {
    description = "Alternative (and improved) Home Connect integration for Home Assistant";
    homepage = "https://github.com/ekutner/home-connect-hass";
    changelog = "https://github.com/ekutner/home-connect-hass/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kranzes ];
  };
}
