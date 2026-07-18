{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "tsidp";
  version = "0.0.14";

  src = fetchFromGitHub {
    owner = "tailscale";
    repo = "tsidp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AZ0fAQag+pY5uYq2loQClkk0BqvC7e5C+KcI6J9g8Pw=";
  };

  vendorHash = "sha256-sycTIr6cRY2BLve23vvpk7mhiV/jrP26SoLHxY7tznw=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple OIDC / OAuth Identity Provider (IdP) server for your tailnet";
    homepage = "https://github.com/tailscale/tsidp";
    changelog = "https://github.com/tailscale/tsidp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ akotro ];
    mainProgram = "tsidp";
  };
})
