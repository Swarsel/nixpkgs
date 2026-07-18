{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "3.4.3";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-sun2";
    tag = version;
    hash = "sha256-UATxuKTusDkKLWwJq2CupPcF/TIKAmE5VPo3054cwKc=";
  };

  domain = "sun2";
  owner = "pnbruckner";

  meta = rec {
    description = "Home Assistant Sun2 sensor";
    homepage = "https://github.com/pnbruckner/ha-sun2";
    changelog = "${homepage}/releases/tag/${version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ sephalon ];
  };
}
