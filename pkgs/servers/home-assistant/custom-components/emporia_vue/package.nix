{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pyemvue,
}:

buildHomeAssistantComponent rec {
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "magico13";
    repo = "ha-emporia-vue";
    rev = "v${version}";
    hash = "sha256-3S9ko1CN8eM3xVl91bwfLnRwU5T5bgXnY6slQ3u8Lk4=";
  };

  dependencies = [
    pyemvue
  ];

  domain = "emporia_vue";

  ignoreVersionRequirement = [
    "boto3"
    "pyemvue"
  ];

  owner = "magico13";

  meta = {
    description = "Reads data from the Emporia Vue energy monitor into Home Assistant";
    homepage = "https://github.com/magico13/ha-emporia-vue";
    changelog = "https://github.com/magico13/ha-emporia-vue/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ presto8 ];
  };
}
