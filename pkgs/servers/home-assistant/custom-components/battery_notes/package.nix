{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "3.4.8";

  src = fetchFromGitHub {
    inherit owner;
    repo = "HA-Battery-Notes";
    tag = version;
    hash = "sha256-Kc4ATfEEi8SRvl10msLotmBa3/RNff2yD4moRPsk8j8=";
  };

  # has no tests
  doCheck = false;
  domain = "battery_notes";
  owner = "andrew-codechimp";

  meta = {
    description = "Home Assistant integration to provide battery details of devices";
    homepage = "https://github.com/andrew-codechimp/HA-Battery-Notes";
    changelog = "https://github.com/andrew-codechimp/HA-Battery-Notes/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
