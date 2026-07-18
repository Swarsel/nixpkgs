{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "go-task";
  version = "3.48.0";

  src = fetchFromGitHub {
    owner = "go-task";
    repo = "task";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t6u2SSPDh+zj8M5aJfP3mYgSgBMNDEMNhMWEkr86M0U=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-v8OY4JkDaY8Xl20JvU8JbAXD43BaGrM5UmiJHnHaxek=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    ln -s $out/bin/task $out/bin/go-task
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd task \
      --bash <($out/bin/task --completion bash) \
      --fish <($out/bin/task --completion fish) \
      --zsh <($out/bin/task --completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/go-task/task/v3/internal/version.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/task" ];
  versionCheckProgram = "${placeholder "out"}/bin/task";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Task runner / simpler Make alternative written in Go";
    homepage = "https://taskfile.dev/";
    changelog = "https://github.com/go-task/task/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ parasrah ];
  };
})
