{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "1.5.7";

  src = fetchFromGitHub {
    owner = "thomasddn";
    repo = "ha-volvo-cars";
    tag = "v${version}";
    hash = "sha256-2wRqEa7jVumbRNCGrFa0gYEzgGwUrMnW2A8JhPTTMCc=";
  };

  domain = "volvo_cars";
  owner = "thomasddn";

  meta = {
    description = "Volvo Cars Home Assistant integration";
    homepage = "https://github.com/thomasddn/ha-volvo-cars";
    changelog = "https://github.com/thomasddn/ha-volvo-cars/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      matteopacini
      seberm
    ];
  };
}
