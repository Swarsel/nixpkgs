{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  volkswagencarnet,
}:

buildHomeAssistantComponent rec {
  version = "5.4.11";

  src = fetchFromGitHub {
    owner = "robinostlund";
    repo = "homeassistant-volkswagencarnet";
    tag = "v${version}";
    hash = "sha256-soSTa6FYnNpzsl5goKS9xcSnubiXXUUGOJ3tDgbFDc8=";
  };

  postPatch = ''
    python3 manage/update_manifest.py --version '${version}'
  '';

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [ volkswagencarnet ];
  domain = "volkswagencarnet";
  owner = "robinostlund";

  meta = {
    description = "Volkswagen Connect component for Home Assistant";
    homepage = "https://github.com/robinostlund/homeassistant-volkswagencarnet";
    changelog = "https://github.com/robinostlund/homeassistant-volkswagencarnet/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
