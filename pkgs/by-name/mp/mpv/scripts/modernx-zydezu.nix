{
  lib,
  fetchFromGitHub,
  buildLua,
  installFonts,
  makeFontsConf,
  mpvScripts,
  nix-update-script,
}:
buildLua (finalAttrs: {
  pname = "modernx-zydezu";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "zydezu";
    repo = "ModernX";
    rev = finalAttrs.version;
    hash = "sha256-jK35LmihSCF789AJhKlySg6fXurAe5uuHNsgFjt0+iY=";
  };

  nativeBuildInputs = [ installFonts ];
  scriptPath = "modernx.lua";
  # FIXME?: collides with mpvScripts.modernx
  passthru.dontCollideCheck = lib.hasAttr "modernx" mpvScripts;

  passthru.extraWrapperArgs = [
    "--set"
    "FONTCONFIG_FILE"
    (toString (makeFontsConf {
      fontDirectories = [ "${finalAttrs.finalPackage}/share/fonts" ];
    }))
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern OSC UI replacement for MPV that retains the functionality of the default OSC";
    homepage = "https://github.com/zydezu/ModernX";
    changelog = "https://github.com/zydezu/ModernX/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      Guanran928
    ];
  };
})
