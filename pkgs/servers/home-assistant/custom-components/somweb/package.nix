{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  somweb,
}:

buildHomeAssistantComponent rec {
  version = "1.1.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "home-assistant-component-somweb";
    tag = "v${version}";
    hash = "sha256-anOcpaGeblFVaP2EFVuxx1EuXnNgxy/QoYqvYJMv1Fo=";
  };

  dependencies = [ somweb ];
  domain = "somweb";
  owner = "taarskog";

  meta = {
    description = "Custom component for Home Assistant to manage garage doors and gates by Sommer through SOMweb";
    homepage = "https://github.com/taarskog/home-assistant-component-somweb";
    changelog = "https://github.com/taarskog/home-assistant-component-somweb/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
  };
}
