{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  fetchNpmDeps,
  nodejs,
  npmHooks,
}:

buildHomeAssistantComponent rec {
  version = "3.0.2";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hass-browser_mod";
    tag = "v${version}";
    hash = "sha256-5OzM3fzoDIiy46/MEJnYpgw3pOGWwVgCyQeorFRQm9M=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmBuildHook
    npmHooks.npmConfigHook
  ];

  domain = "browser_mod";
  npmBuildScript = "build";

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-4S8v0YWm3mom+U6Kk09u/eBQFccoSjxHwwTwCH3qSGQ=";
  };

  owner = "thomasloven";

  meta = {
    description = "Home Assistant integration to turn your browser into a controllable entity and media player";
    homepage = "https://github.com/thomasloven/hass-browser_mod";
    changelog = "https://github.com/thomasloven/hass-browser_mod/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
