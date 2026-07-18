{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  charset-normalizer,
  pycountry,
  xmltodict,
}:

buildHomeAssistantComponent rec {
  version = "0.43.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-smartthinq-sensors";
    rev = "v${version}";
    hash = "sha256-QD7p6yldjqgcZTRjztuLsHTBh+PDOQjLq5BGjw5yg8o=";
  };

  dependencies = [
    charset-normalizer
    pycountry
    xmltodict
  ];

  domain = "smartthinq_sensors";
  owner = "ollo69";

  meta = {
    description = "Home Assistant custom integration for SmartThinQ LG devices configurable with Lovelace User Interface";
    homepage = "https://github.com/ollo69/ha-smartthinq-sensors";
    changelog = "https://github.com/ollo69/ha-smartthinq-sensors/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ k900 ];
  };
}
