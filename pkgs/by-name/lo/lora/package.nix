{
  lib,
  fetchFromGitHub,
  installFonts,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lora";
  version = "3.021";

  src = fetchFromGitHub {
    owner = "cyrealtype";
    repo = "Lora-Cyrillic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v9wE9caI9HTCfO01Yf+s6KajF7WpnL12nu+IuOV7T+w=";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [ installFonts ];

  # installFonts adds a hook to `postInstall` that installs fonts
  # into the correct directories
  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lora Font: well-balanced contemporary serif with roots in calligraphy";
    homepage = "https://github.com/cyrealtype/Lora-Cyrillic";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ ofalvai ];
    platforms = lib.platforms.all;
  };
})
