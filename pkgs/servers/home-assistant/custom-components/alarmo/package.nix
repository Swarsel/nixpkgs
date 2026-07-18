{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "1.10.18";

  src = fetchFromGitHub {
    owner = "nielsfaber";
    repo = "alarmo";
    tag = "v${version}";
    hash = "sha256-SBR/NVz7E+gsVLnEO3o30irNeFnnBZb5YVJImWHLk2Y=";
  };

  postPatch = ''
    find ./custom_components/alarmo/frontend -mindepth 1 -maxdepth 1 ! -name "dist" -exec rm -rf {} \;
  '';

  domain = "alarmo";
  owner = "nielsfaber";

  meta = {
    description = "Alarm System for Home Assistant";
    homepage = "https://github.com/nielsfaber/alarmo";
    changelog = "https://github.com/nielsfaber/alarmo/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mindstorms6 ];
  };
}
