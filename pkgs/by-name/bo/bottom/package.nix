{
  lib,
  stdenv,
  fetchFromGitHub,
  autoAddDriverRunpath,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bottom";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "ClementTsang";
    repo = "bottom";
    tag = finalAttrs.version;
    hash = "sha256-axzZEviUVosXo5XzQB32A2+sUdiLzEtjZg52Z6hp4lM=";
  };

  nativeBuildInputs = [
    autoAddDriverRunpath
    installShellFiles
  ];

  cargoHash = "sha256-RUFlv95VoRhfHeIXWFWWtbwn71uJnEYoi2NozU4ybK8=";

  env = {
    BTM_GENERATE = true;
  };

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    # fails to get list of processes due to sandboxing, this functionality works at runtime
    "--skip=collection::tests::test_data_collection"
  ];

  postInstall = ''
    installManPage target/tmp/bottom/manpage/btm.1
    installShellCompletion \
      target/tmp/bottom/completion/btm.{bash,fish} \
      --zsh target/tmp/bottom/completion/_btm

    install -Dm444 desktop/bottom.desktop -t $out/share/applications
    install -Dm644 assets/icons/bottom-system-monitor.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/btm";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-platform graphical process/system monitor with a customizable interface";
    homepage = "https://github.com/ClementTsang/bottom";
    changelog = "https://github.com/ClementTsang/bottom/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      berbiche
      gepbird
    ];

    mainProgram = "btm";
  };
})
