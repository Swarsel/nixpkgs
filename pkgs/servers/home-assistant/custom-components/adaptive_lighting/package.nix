{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  ulid-transform,
}:

buildHomeAssistantComponent rec {
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "basnijholt";
    repo = "adaptive-lighting";
    tag = "v${version}";
    hash = "sha256-L00M+74ZgJmUje5c/TBkBlsjCrqPt7i/8hH8SU5cnRc=";
  };

  dependencies = [
    ulid-transform
  ];

  domain = "adaptive_lighting";
  owner = "basnijholt";

  meta = {
    description = "Home Assistant Adaptive Lighting Plugin - Sun Synchronized Lighting";
    homepage = "https://github.com/basnijholt/adaptive-lighting";
    changelog = "https://github.com/basnijholt/adaptive-lighting/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mindstorms6 ];
  };
}
