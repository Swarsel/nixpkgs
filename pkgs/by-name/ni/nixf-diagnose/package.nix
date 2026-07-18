{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixf-diagnose";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "inclyc";
    repo = "nixf-diagnose";
    tag = finalAttrs.version;
    hash = "sha256-vHW2AnUxBuG9mlpMB0f9eK4M1VlJPm5YtwjXksx/uik=";
  };

  cargoHash = "sha256-L6wiYUzlzginjhu23EBPAteZ2nTIqUE6mC2q1yfKWs4=";
  env.NIXF_TIDY_PATH = lib.getExe nixf;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI wrapper for nixf-tidy with fancy diagnostic output";
    homepage = "https://github.com/inclyc/nixf-diagnose";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ inclyc ];
    mainProgram = "nixf-diagnose";
  };
})
