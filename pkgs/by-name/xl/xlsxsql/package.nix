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
  pname = "xlsxsql";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "noborus";
    repo = "xlsxsql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-07Gnw1Y8TyxoOMMevnx4tGyk6k7n4o3gDaOPshsmcSE=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-3r7KY6boNYd2tJjMExiTZD1ZxQhm2UlP/Gyic8XMGrw=";

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd xlsxsql \
        --bash <(${emulator} $out/bin/xlsxsql completion bash) \
        --fish <(${emulator} $out/bin/xlsxsql completion fish) \
        --zsh <(${emulator} $out/bin/xlsxsql completion zsh)
    ''
  );

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X main.version=v${finalAttrs.version}"
    "-X main.revision=${finalAttrs.src.rev}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool that executes SQL queries on various files including xlsx files and outputs the results to various files";
    homepage = "https://github.com/noborus/xlsxsql";
    changelog = "https://github.com/noborus/xlsxsql/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    mainProgram = "xlsxsql";
  };
})
