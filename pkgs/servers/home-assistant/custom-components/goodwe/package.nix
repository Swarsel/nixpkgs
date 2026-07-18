{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  goodwe,
}:

buildHomeAssistantComponent rec {
  version = "0.9.9.31";

  src = fetchFromGitHub {
    owner = "mletenay";
    repo = "home-assistant-goodwe-inverter";
    tag = "v${version}";
    hash = "sha256-aq3m1+XBE0f/+r3RiSXU1XFq+vUwKs0phis2B34c/8w=";
  };

  dependencies = [
    goodwe
  ];

  domain = "goodwe";
  ignoreVersionRequirement = [ "goodwe" ];
  owner = "mletenay";

  meta = {
    description = "Experimental version of Home Assistant integration for Goodwe solar inverters";
    homepage = "https://github.com/mletenay/home-assistant-goodwe-inverter";
    changelog = "https://github.com/mletenay/home-assistant-goodwe-inverter/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ netpleb ];
  };
}
