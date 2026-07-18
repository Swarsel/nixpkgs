{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
}:

buildHomeAssistantComponent rec {
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "Hypfer";
    repo = "hass-scene_presets";
    tag = version;
    hash = "sha256-Vhowtosxgx7yDprm2ziBe3fSUqNxfP3ULmhP7ETsbzY=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    npmHooks.npmBuildHook
  ];

  postInstall = ''
    # Create custom presets directory to satisfy Python set-up code
    mkdir -p "$out/custom_components/scene_presets/userdata/custom/assets"
  '';

  domain = "scene_presets";
  npmBuildScript = "build";

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-whBM/Z6ib8YNP3BgpJgU2O9ruxovUI84E5/ZbpHK26Y=";
  };

  owner = "Hypfer";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hue-like scene presets for lights in Home Assistant";
    homepage = "https://github.com/Hypfer/hass-scene_presets";
    changelog = "https://github.com/Hypfer/hass-scene_presets/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jpds ];
  };
}
