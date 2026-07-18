{
  lib,
  fetchFromGitea,
  iwqr,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iwqr";
  version = "0.1.1";

  src = fetchFromGitea {
    owner = "kreny";
    repo = "iwqr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z9CjCJvi6MlZGghZKx13gGSKwUnECAf0cr9P2ABskh0=";
    domain = "git.kroner.dev";
  };

  cargoHash = "sha256-wnthAp/oV6W7G/a5JXYwzni+qGzDiVefIjRamkJ5jQc=";

  passthru = {
    tests.version = testers.testVersion {
      package = iwqr;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool for generating qr codes for iwd networks";
    homepage = "https://git.kroner.dev/kreny/iwqr";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ h7x4 ];
    mainProgram = "iwqr";
  };
})
