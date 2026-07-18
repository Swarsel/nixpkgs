{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "talhelper";
  version = "3.1.13";

  src = fetchFromGitHub {
    owner = "budimanjojo";
    repo = "talhelper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AKyyrslc2bNLBvZ6KjQOHnVIX1ESnE7OZyF8aucctdI=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-mXM7c6T5qcAHez5QrmxFmGE0DLyL2RADIFTdrQaH2GQ=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd talhelper \
      --bash <($out/bin/talhelper completion bash) \
      --fish <($out/bin/talhelper completion fish) \
      --zsh <($out/bin/talhelper completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/budimanjojo/talhelper/v3/cmd.version=v${finalAttrs.version}"
  ];

  subPackages = [
    "."
    "./cmd"
  ];

  meta = {
    description = "Help creating Talos kubernetes cluster";

    longDescription = ''
      Talhelper is a helper tool to help creating Talos Linux cluster
      in your GitOps repository.
    '';

    homepage = "https://github.com/budimanjojo/talhelper";
    changelog = "https://github.com/budimanjojo/talhelper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      madeddie
      nevivurn
    ];

    mainProgram = "talhelper";
  };
})
