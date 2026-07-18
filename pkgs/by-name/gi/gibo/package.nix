{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
buildGoModule (finalAttrs: {
  pname = "gibo";
  version = "3.0.21";

  src = fetchFromGitHub {
    owner = "simonwhitaker";
    repo = "gibo";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-XPJy5dDQllnffz8BxJ6BYoFZCf7/x8a/6K6o0mRmKsI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-JMViyQHqq2bkKuOcw+lbjkomoRv0kIqxMfE1Uu7rgfs=";

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd gibo \
        --bash <(${emulator} $out/bin/gibo completion bash) \
        --fish <(${emulator} $out/bin/gibo completion fish) \
        --zsh <(${emulator} $out/bin/gibo completion zsh)
    ''
  );

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/simonwhitaker/gibo/cmd.version=${finalAttrs.version}"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Shell script for easily accessing gitignore boilerplates";
    homepage = "https://github.com/simonwhitaker/gibo";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.unix;
    mainProgram = "gibo";
  };
})
