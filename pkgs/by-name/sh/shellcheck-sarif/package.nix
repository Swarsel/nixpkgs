{
  lib,
  fetchCrate,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shellcheck-sarif";
  version = "0.8.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-G69DiDl78vkPuLodsRTL7dbbIFtNNF/XWuLZpCHKJws=";
  };

  cargoHash = "sha256-ZA7l7fmQG1wjT8oLVp6w2okPlwfNGQw/7qrH3rRS+0o=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI tool to convert shellcheck diagnostics into SARIF";
    homepage = "https://psastras.github.io/sarif-rs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "shellcheck-sarif";
  };
})
