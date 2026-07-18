{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "1.19.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-pi-hole-v6";
    tag = "v${version}";
    hash = "sha256-2aEdiCNNHQH6HpOMxnwneWab9pvJTQbPvdU+Vm3Gm3Y=";
  };

  # has no tests
  doCheck = false;
  domain = "pi_hole_v6";
  owner = "bastgau";

  meta = {
    description = "Pi-hole V6 Integration for Home Assistant";

    longDescription = ''
      This custom integration restored compatibility between Home Assistant and Pi-hole, which was no longer supported by the native integration.
      Today, this integration offers additional and complementary features.
    '';

    homepage = "https://github.com/bastgau/ha-pi-hole-v6";
    changelog = "https://github.com/bastgau/ha-pi-hole-v6/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
