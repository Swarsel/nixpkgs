{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

# fails with go 1.25, downgrade to 1.24
# error tls.ConnectionState: struct field count mismatch: 17 vs 16
buildGoModule (finalAttrs: {
  pname = "warp-plus";
  version = "1.2.6-unstable-2025-11-17";

  src = fetchFromGitHub {
    owner = "bepass-org";
    repo = "warp-plus";
    rev = "f70ea7e4f193717c73f9a4357cbc98d6944b36bb";
    hash = "sha256-5H0iF+dc+3qQrFCPiaBxHMSoHsmciKvwX1SJX7TMjeE=";
  };

  patches = [
    # https://github.com/bepass-org/warp-plus/pull/291
    ./fix-endpoints.patch
  ];

  vendorHash = "sha256-FqyNjnCoeOCraVv9WhQIw+PxrJVfOu2dAnINi++nsW4=";
  nativeCheckInputs = [ versionCheckHook ];

  checkFlags =
    let
      # Skip tests that require network access
      skippedTests = [
        "TestStdNetBindReceiveFuncAfterClose"
        "TestConcurrencySafety"
        "TestNoiseHandshake"
        "TestTwoDevicePing"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  doInstallCheck = true;

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Warp + Psiphon, an anti censorship utility for Iran";
    homepage = "https://github.com/bepass-org/warp-plus";
    changelog = "https://github.com/bepass-org/warp-plus/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "warp-plus";
    broken = true;
  };
})
