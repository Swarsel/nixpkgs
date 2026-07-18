{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pysolarmanv5,
  pyyaml,
}:

buildHomeAssistantComponent rec {
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "StephanJoubert";
    repo = "home_assistant_solarman";
    tag = version;
    hash = "sha256-+znRq7LGIxbxMEypIRqbIMgV8H4OyiOakmExx1aHEl8=";
  };

  dependencies = [
    pysolarmanv5
    pyyaml
  ];

  domain = "solarman";
  owner = "StephanJoubert";

  meta = {
    description = "Home Assistant component for Solarman collectors used with a variety of inverters";
    homepage = "https://github.com/StephanJoubert/home_assistant_solarman";
    changelog = "https://github.com/StephanJoubert/home_assistant_solarman/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Scrumplex ];
  };
}
