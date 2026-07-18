{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "oras";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "oras-project";
    repo = "oras";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kGPHW+SSmCJhvhGxpzKFlc80sjYqeCEmwr/f0ltILE4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-TDYvYmzAgkL+ZrYKt9HTW7NQAGxd/cYu7e7MRYbW8ho=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd oras \
      --bash <($out/bin/oras completion bash) \
      --fish <($out/bin/oras completion fish) \
      --zsh <($out/bin/oras completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  excludedPackages = [ "./test/e2e" ];

  ldflags = [
    "-s"
    "-w"
    "-X oras.land/oras/internal/version.Version=${finalAttrs.version}"
    "-X oras.land/oras/internal/version.BuildMetadata="
    "-X oras.land/oras/internal/version.GitTreeState=clean"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Distribute artifacts across OCI registries with ease";
    homepage = "https://oras.land/";
    changelog = "https://github.com/oras-project/oras/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jk
      developer-guy
    ];

    mainProgram = "oras";
  };
})
