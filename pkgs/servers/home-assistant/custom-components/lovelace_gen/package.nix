{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  jinja2,
}:

buildHomeAssistantComponent rec {
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "thomasloven";
    repo = "hass-lovelace_gen";
    tag = version;
    hash = "sha256-YGqvdoOs9/Etfldoee3mgDQjtveLa/LovwX/IduYyjg=";
  };

  dependencies = [ jinja2 ];
  domain = "lovelace_gen";
  owner = "thomasloven";

  meta = with lib; {
    description = "Improve the lovelace yaml parser for Home Assistant";
    homepage = "https://github.com/thomasloven/hass-lovelace_gen";
    changelog = "https://github.com/thomasloven/hass-lovelace_gen/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ jpinz ];
  };
}
