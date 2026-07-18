{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "budget-tracker-tui";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "Feromond";
    repo = "budget_tracker_tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rVNAYMfTGYRepeNSlm+d/bJq11lRNFZjpoQjQpclSzY=";
  };

  cargoHash = "sha256-u9XlckBJCRzpmY+Hs5x9cBWtxIN1zwMuIYMCuS7i6rQ=";
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal User Interface (TUI) budget tracker";
    homepage = "https://github.com/Feromond/budget_tracker_tui";
    changelog = "https://github.com/Feromond/budget_tracker_tui/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tomasrivera ];
    mainProgram = "Budget_Tracker";
  };
})
