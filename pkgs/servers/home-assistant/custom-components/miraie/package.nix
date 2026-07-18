{
  lib,
  fetchFromGitHub,
  aiomqtt,
  buildHomeAssistantComponent,
  miraie-ac,
  nix-update-script,
}:

buildHomeAssistantComponent rec {
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "rkzofficial";
    repo = "ha-miraie-ac";
    tag = "v${version}";
    hash = "sha256-MYSxBtNvJQmnrtFszL41OFcvv2LKPTpTkbvUKLiqpzs=";
  };

  dependencies = [
    miraie-ac
    aiomqtt
  ];

  domain = "miraie";
  owner = "rkzofficial";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant component for Miraie ACs";
    homepage = "https://github.com/rkzofficial/ha-miraie-ac";
    changelog = "https://github.com/rkzofficial/ha-miraie-ac/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ananthb ];
  };
}
