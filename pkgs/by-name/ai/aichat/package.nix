{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aichat";
  version = "0.30.0";

  src = fetchFromGitHub {
    owner = "sigoden";
    repo = "aichat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xgTGii1xGtCc1OLoC53HAtQ+KVZNO1plB2GVtVBBlqs=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  cargoHash = "sha256-u2JBPm03qvuLEUOEt4YL9O750V2QPgZbxvsvlTQe2nk=";

  postInstall = ''
    installShellCompletion ./scripts/completions/aichat.{bash,fish,zsh}
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Use GPT-4(V), Gemini, LocalAI, Ollama and other LLMs in the terminal";
    homepage = "https://github.com/sigoden/aichat";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mwdomino ];
    mainProgram = "aichat";
  };
})
