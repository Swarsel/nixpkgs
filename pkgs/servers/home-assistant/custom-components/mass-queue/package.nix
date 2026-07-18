{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  music-assistant-client,
}:

buildHomeAssistantComponent rec {
  version = "0.10.1";

  src = fetchFromGitHub {
    inherit owner;
    repo = "mass_queue";
    tag = "v${version}";
    hash = "sha256-Q41/DAwXByeq0Qim3U735XYpLsI2DQqe5r1mJ3N/I2w=";
  };

  # tests are being fixed in https://github.com/droans/mass_queue/pull/107
  doCheck = false;

  dependencies = [
    music-assistant-client
  ];

  domain = "mass_queue";
  owner = "droans";

  meta = {
    description = "Actions to control player queues for Music Assistant";
    homepage = "https://github.com/droans/mass_queue";
    changelog = "https://github.com/droans/mass_queue/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
