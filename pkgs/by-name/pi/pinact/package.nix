{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

let
  mainProgram = "pinact";
in
buildGoModule (finalAttrs: {
  pname = "pinact";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "pinact";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wZ0Q4OCjTRUUZCbZzF4DxMLi/UBtun6TszJhU9LdGd8=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-j/XXuVUZAADJqogMkERK801rACywy62oZW6iGrz5U0k=";
  env.CGO_ENABLED = 0;
  doCheck = true;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd '${mainProgram}' \
      --bash <("$out/bin/${mainProgram}" completion bash) \
      --zsh <("$out/bin/${mainProgram}" completion zsh) \
      --fish <("$out/bin/${mainProgram}" completion fish)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version} -X main.commit=v${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/pinact"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${mainProgram}";
  versionCheckProgramArg = "version";

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex=^v([\\d\\.]+)$"
      ];
    };
  };

  meta = {
    inherit mainProgram;
    description = "Pin GitHub Actions versions";
    homepage = "https://github.com/suzuki-shunsuke/pinact";
    changelog = "https://github.com/suzuki-shunsuke/pinact/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kachick ];
  };
})
