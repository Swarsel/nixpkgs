{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tuxedo";
  version = "2026.6.3";

  src = fetchFromGitHub {
    owner = "webstonehq";
    repo = "tuxedo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1uTa+S1bUyBsWy5FpmXFbggFc7lMbnDKul0h1O4NvMI=";
  };

  cargoHash = "sha256-PIhtD0/0hxFOn51PwOWCtz82a2dvhS+2jbd8Wvr/JUM=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [
    # Failure
    "--skip=insert_dialog_after_nl_parse"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "fast, keyboard-driven terminal UI for todo.txt";
    homepage = "https://github.com/webstonehq/tuxedo";
    changelog = "https://github.com/webstonehq/tuxedo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ iogamaster ];
    mainProgram = "tuxedo";
  };
})
