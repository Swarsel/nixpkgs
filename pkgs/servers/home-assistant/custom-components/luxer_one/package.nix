{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "tjhorner";
    repo = "home-assistant-luxer-one";
    tag = "v${version}";
    hash = "sha256-bzAdroFE25L0gy1FURYF5p8BaTjzHKtmpKWweDAQH0s=";
  };

  domain = "luxer";
  owner = "tjhorner";

  meta = {
    description = "Home Assistant integration for Luxer One";
    homepage = "https://github.com/tjhorner/home-assistant-luxer-one";
    changelog = "https://github.com/tjhorner/home-assistant-luxer-one/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.haylin ];
  };
}
