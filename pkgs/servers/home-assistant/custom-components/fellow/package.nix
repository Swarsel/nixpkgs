{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pydantic,
  requests,
  unstableGitUpdater,
}:

buildHomeAssistantComponent rec {
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "kristofferR";
    repo = "FellowAiden-HomeAssistant";
    tag = "v${version}";
    hash = "sha256-n1D/kP1vxc+/kgZGwl+5nLD6IzERmMXeiQjSKZGiqvc=";
  };

  dependencies = [
    requests
    pydantic
  ];

  domain = "fellow";
  owner = "kristofferR";
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Home Assistant integration for Fellow Aiden coffee brewer";
    homepage = "https://github.com/kristofferR/FellowAiden-HomeAssistant";
    changelog = "https://github.com/kristofferR/FellowAiden-HomeAssistant/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
