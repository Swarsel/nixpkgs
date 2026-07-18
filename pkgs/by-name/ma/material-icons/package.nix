{
  lib,
  fetchFromGitHub,
  installFonts,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "material-icons";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "material-design-icons";
    rev = finalAttrs.version;
    hash = "sha256-wX7UejIYUxXOnrH2WZYku9ljv4ZAlvgk8EEJJHOCCjE=";
  };

  nativeBuildInputs = [ installFonts ];
  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "System status icons by Google, featuring material design";
    homepage = "https://material.io/icons";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mpcsh ];
    platforms = lib.platforms.all;
  };
})
