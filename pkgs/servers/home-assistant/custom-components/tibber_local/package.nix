{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  smllib,
}:

buildHomeAssistantComponent rec {
  version = "2026.6.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-tibber-pulse-local";
    tag = version;
    hash = "sha256-Mssjizh9DcA6fldwl6QmmgG8aOVwvF5d0akqrkArM5g=";
  };

  dependencies = [
    smllib
  ];

  domain = "tibber_local";
  owner = "marq24";

  meta = {
    description = "Local/LAN Tibber Pulse IR/Bridge Integration for Home Assistant";
    homepage = "https://github.com/marq24/ha-tibber-pulse-local";
    changelog = "https://github.com/marq24/ha-tibber-pulse-local/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hensoko ];
  };
}
