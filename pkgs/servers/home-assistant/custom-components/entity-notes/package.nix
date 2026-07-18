{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  voluptuous,
}:

buildHomeAssistantComponent rec {
  version = "3.3.11";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-entity-notes";
    tag = "v${version}";
    hash = "sha256-J+HIa8VgfObhuOY8jn39hQH3I4DEgVn65U9w9a/vNd4=";
  };

  dependencies = [
    voluptuous
  ];

  domain = "entity_notes";
  owner = "martindell";

  meta = {
    description = "Home Assistant custom component for adding notes to entities";
    homepage = "https://github.com/martindell/ha-entity-notes";
    changelog = "https://github.com/martindell/ha-entity-notes/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
