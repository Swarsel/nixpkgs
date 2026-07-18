{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "guesswidth";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "noborus";
    repo = "guesswidth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MbQBfwXdmcSU6F7M+Y70lGwBwhhJvRgtevco+UPt0Po=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-/R/KUKQq52CnukJoQybSA4OkcHq/v8ICxxUqSc4ynEQ=";

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd guesswidth \
        --bash <(${emulator} $out/bin/guesswidth completion bash) \
        --fish <(${emulator} $out/bin/guesswidth completion fish) \
        --zsh <(${emulator} $out/bin/guesswidth completion zsh)
    ''
  );

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X github.com/noborus/guesswidth.version=v${finalAttrs.version}"
    "-X github.com/noborus/guesswidth.revision=${finalAttrs.src.rev}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Guess the width (fwf) output without delimiters in commands that output to the terminal";
    homepage = "https://github.com/noborus/guesswidth";
    changelog = "https://github.com/noborus/guesswidth/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    mainProgram = "guesswidth";
  };
})
