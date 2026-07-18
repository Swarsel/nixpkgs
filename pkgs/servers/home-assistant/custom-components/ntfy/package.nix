{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  requests,
}:

buildHomeAssistantComponent rec {
  version = "1.2.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "homeassistant_integration_ntfy";
    rev = "v${version}";
    hash = "sha256-cy4aHrUdFlMGQt9we0pA8TEGffQEGptZoaSKxwXD4kM=";
  };

  dependencies = [
    requests
  ];

  domain = "ntfy";
  owner = "hbrennhaeuser";

  meta = {
    description = "Send notifications with ntfy.sh and selfhosted ntfy-servers";
    homepage = "https://github.com/hbrennhaeuser/homeassistant_integration_ntfy";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      koral
      baksa
    ];
  };
}
