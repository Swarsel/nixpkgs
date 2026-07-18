{
  lib,
  fetchFromGitHub,
  buildLua,
  installFonts,
  makeFontsConf,
  nix-update-script,
}:
buildLua (finalAttrs: {
  pname = "modernx";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "cyl0";
    repo = "ModernX";
    rev = finalAttrs.version;
    hash = "sha256-q7DwyfmOIM7K1L7vvCpq1EM0RVpt9E/drhAa9rLYb1k=";
  };

  nativeBuildInputs = [ installFonts ];
  scriptPath = "modernx.lua";

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
    homepage = "https://github.com/cyl0/ModernX";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ Guanran928 ];
  };
})
