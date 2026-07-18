{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "1.3.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass_ingress";
    tag = version;
    hash = "sha256-TvKmWDYiO4HlRWdsoya2fJalbIQnMzDodQWB9o6yGAo=";
  };

  domain = "ingress";
  owner = "lovelylain";

  meta = {
    description = "Add additional ingress panels to your Home Assistant frontend";
    homepage = "https://github.com/lovelylain/hass_ingress";
    changelog = "https://github.com/lovelylain/hass_ingress/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ David-Kopczynski ];
  };
}
