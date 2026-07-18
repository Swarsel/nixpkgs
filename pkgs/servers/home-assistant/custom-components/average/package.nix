{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  version = "2.4.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "ha-average";
    tag = version;
    hash = "sha256-LISGpgfoVxdOeJ9LHzxf7zt49pbIJrLiPkNg/Mf1lxM=";
  };

  postPatch = ''
    sed -i "/pip>=/d" custom_components/average/manifest.json
  '';

  domain = "average";
  owner = "Limych";

  meta = {
    description = "Average Sensor for Home Assistant";
    homepage = "https://github.com/Limych/ha-average";
    changelog = "https://github.com/Limych/ha-average/releases/tag/${version}";
    license = lib.licenses.cc-by-nc-40;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
  };
}
