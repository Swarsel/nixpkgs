{
  lib,
  fetchFromGitHub,
  alphaessopenapi,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "CharlesGillanders";
    repo = "homeassistant-alphaESS";
    tag = "v${version}";
    hash = "sha256-7IswE+Eqdo+hXic4MQ+vx6lBAudoQPW80eT6AEPFDjQ=";
  };

  dependencies = [
    alphaessopenapi
  ];

  domain = "alphaess";
  owner = "CharlesGillanders";

  meta = {
    description = "Monitor your energy generation, storage, and usage data using the official API from Alpha ESS";
    homepage = "https://github.com/CharlesGillanders/homeassistant-alphaESS";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ benediktbroich ];
  };
}
