{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tcping-rs";
  version = "1.2.27";

  src = fetchFromGitHub {
    owner = "lvillis";
    repo = "tcping-rs";
    tag = finalAttrs.version;
    hash = "sha256-7VbuSGT1EGHvKoccLfd8Y5TBaPIMKzZ9eaCVrZPNz34=";
  };

  cargoHash = "sha256-O94qItpOhLyWxdj7TXljacMbufbYGZw4F5FRS/o7qME=";

  checkFlags = [
    # This test requires external network access
    "--skip=resolve_domain"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TCP Ping (tcping) Utility for Port Reachability";
    homepage = "https://github.com/lvillis/tcping-rs";
    changelog = "https://github.com/lvillis/tcping-rs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ heitorPB ];
    mainProgram = "tcping";
  };
})
