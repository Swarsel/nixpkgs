{
  lib,
  fetchFromGitHub,
  gfold,
  mold,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gfold";
  version = "2026.3.0";

  src = fetchFromGitHub {
    owner = "nickgerace";
    repo = "gfold";
    tag = finalAttrs.version;
    hash = "sha256-iQWcRApAxWGrztEPtsKeaTWcM8gO0CQUA8tNia+bZ1I=";
  };

  nativeBuildInputs = [ mold ];
  cargoHash = "sha256-N7dgB0yzL5JSdQOAhNL9pnCSpV/Mo0Phe6ljwipLD/8=";

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "gfold --version";
      package = gfold;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI tool to help keep track of your Git repositories, written in Rust";
    homepage = "https://github.com/nickgerace/gfold";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.unix;
    mainProgram = "gfold";
  };
})
