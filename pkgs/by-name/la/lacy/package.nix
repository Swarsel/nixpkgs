{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lacy";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "timothebot";
    repo = "lacy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yPq9iW/Qm28frvpCByE5sM8+VBtM1k/GBeHVAhb6XOc=";
  };

  cargoHash = "sha256-EPoVN3S+vQ1hwxWHUbYy1XSpEkswLDbl29lXV8IVCxA=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast magical cd alternative for lacy terminal navigators";
    homepage = "https://github.com/timothebot/lacy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Srylax ];
    platforms = lib.platforms.all;
    mainProgram = "lacy";
  };
})
