{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "metal-cli";
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "equinix";
    repo = "metal-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o2CXcwGowmQ4/BBXZXbR0uJ0AOARj2KbKhhtlRr7qpM=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-oAghUkEhOkpCfRkDF+/Tfo45ihbXJabRkk7J3ghP36I=";
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd metal \
      --bash <($out/bin/metal completion bash) \
      --fish <($out/bin/metal completion fish) \
      --zsh <($out/bin/metal completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/equinix/metal-cli/cmd.Version=${finalAttrs.version}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/metal";

  meta = {
    description = "Official Equinix Metal CLI";
    homepage = "https://github.com/equinix/metal-cli/";
    changelog = "https://github.com/equinix/metal-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "metal";
  };
})
