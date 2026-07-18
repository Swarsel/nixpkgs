{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "create-dmg";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "create-dmg";
    repo = "create-dmg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oWrQT9nuFcJRwwXd5q4IqhG7M77aaazBG0+JSHAzPvw=";
  };

  dontBuild = true;
  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Shell script to build fancy DMGs";
    homepage = "https://github.com/create-dmg/create-dmg";
    changelog = "https://github.com/create-dmg/create-dmg/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ heywoodlh ];
    platforms = lib.platforms.darwin;
    mainProgram = "create-dmg";
  };
})
