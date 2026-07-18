{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pyopensprinkler,
}:

buildHomeAssistantComponent rec {
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "vinteo";
    repo = "hass-opensprinkler";
    tag = "v${version}";
    hash = "sha256-P+VSnMioZGwdsQ053uNiqpZzrtDFPb80FQaKqr3pOT4=";
  };

  dependencies = [
    pyopensprinkler
  ];

  domain = "opensprinkler";
  owner = "vinteo";

  meta = {
    description = "OpenSprinkler Integration for Home Assistant";
    homepage = "https://github.com/vinteo/hass-opensprinkler";
    changelog = "https://github.com/vinteo/hass-opensprinkler/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jfly ];
  };
}
