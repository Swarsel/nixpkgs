{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  replaceVars,
  rustPlatform,
  swift,
  swiftpm,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sentry-cli";
  version = "2.58.2";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry-cli";
    tag = finalAttrs.version;
    hash = "sha256-2dxnAwxIdmeA53PETUyDUgi1T4ZH9faBvPCMdRPUDxw=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    (replaceVars ./fix-swift-lib-path.patch { swiftLib = lib.getLib swift; })
  ];

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    swift
    swiftpm
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-CwULTOZN2TTpB8heLuegID38ub6J3XoiY7l7UW1VcGo=";
  # Needed to get openssl-sys to use pkgconfig.
  env.OPENSSL_NO_VENDOR = 1;
  nativeCheckInputs = [ gitMinimal ];

  checkFlags = [
    "--skip=integration::send_metric::command_send_metric"
    "--skip=integration::update::command_update"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sentry-cli \
        --bash <($out/bin/sentry-cli completions bash) \
        --fish <($out/bin/sentry-cli completions fish) \
        --zsh <($out/bin/sentry-cli completions zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;
  # By default including `swiftpm` in `nativeBuildInputs` will take over `buildPhase`
  dontUseSwiftpmBuild = true;
  dontUseSwiftpmCheck = true;
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line utility to work with Sentry";
    homepage = "https://docs.sentry.io/cli/";
    changelog = "https://github.com/getsentry/sentry-cli/raw/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rizary ];
    mainProgram = "sentry-cli";
  };
})
