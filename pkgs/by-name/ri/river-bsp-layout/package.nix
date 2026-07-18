{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "river-bsp-layout";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "areif-dev";
    repo = "river-bsp-layout";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/R9v3NGsSG4JJtdk0sJX7ahRolRmJMwMP48JRmLffXc=";
  };

  cargoHash = "sha256-kfeRGT/qgZRPfXl03JYRF1CVPIIiGPIdxLORiA6QWu4=";

  meta = {
    description = "Binary space partition / grid layout manager for River WM";
    homepage = "https://github.com/areif-dev/river-bsp-layout";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ areif-dev ];
    platforms = lib.platforms.linux;
    mainProgram = "river-bsp-layout";
  };
})
