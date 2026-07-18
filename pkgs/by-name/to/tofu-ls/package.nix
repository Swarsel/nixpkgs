{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "tofu-ls";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "opentofu";
    repo = "tofu-ls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VBJ4UhurJRDxZD5TJhiZrH6ArNdIirCzBDZzZoWpx9Q=";
  };

  vendorHash = "sha256-D/LaFzgmpqW4xG5V2Ng3O2ogG/maqbHbD0JaXWU/dbQ=";

  checkFlags =
    let
      skippedTests = [
        # Require network access
        "TestCompletion_moduleWithValidData"
        "TestCompletion_multipleModulesWithValidData"
        "TestCompletion_multipleModulesWithValidData"
        "TestExec_cancel"
        "TestLangServer_DidChangeWatchedFiles_moduleInstalled"
        "TestLangServer_workspace_symbol_basic"
        "TestLangServer_workspace_symbol_missing"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  ldflags = [
    "-s"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenTofu Language Server";
    homepage = "https://github.com/opentofu/tofu-ls";
    changelog = "https://github.com/opentofu/tofu-ls/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    mainProgram = "tofu-ls";
  };
})
