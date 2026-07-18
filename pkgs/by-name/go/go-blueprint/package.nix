{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "go-blueprint";
  version = "0.10.11";

  src = fetchFromGitHub {
    owner = "Melkeydev";
    repo = "go-blueprint";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ahvSCu4bqzPmscHSQmaxhbUtlEL7T0T/13RY2sIGWjA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-WBzToupC1/O70OYHbKk7S73OEe7XRLAAbY5NoLL7xvw=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd go-blueprint \
      --bash <($out/bin/go-blueprint completion bash) \
      --fish <($out/bin/go-blueprint completion fish) \
      --zsh <($out/bin/go-blueprint completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s -w -X github.com/melkeydev/go-blueprint/cmd.GoBlueprintVersion=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Initialize Go projects using popular frameworks";
    homepage = "https://github.com/Melkeydev/go-blueprint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tobifroe ];
    mainProgram = "go-blueprint";
  };
})
