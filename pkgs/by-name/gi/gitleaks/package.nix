{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  git,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "gitleaks";
  version = "8.30.1";

  src = fetchFromGitHub {
    owner = "gitleaks";
    repo = "gitleaks";
    tag = "v${version}";
    hash = "sha256-PpMquYyXNN6KFwN/efY5+gr+4IhSKPoAy2M/rcqfW5k=";
  };

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ];

  vendorHash = "sha256-whJtl34dNltH/dk9qWSThcCYXC0x9PzbAUOO97Int+k=";
  nativeCheckInputs = [ git ];

  postInstall = ''
    install -Dm444 config/gitleaks.toml $out/etc/gitleaks.toml
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh <($out/bin/${pname} completion zsh)
  '';

  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/zricethezav/gitleaks/v${lib.versions.major version}/version.Version=${version}"
  ];

  subPackages = [
    "."
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scan git repos (or files) for secrets";

    longDescription = ''
      Gitleaks is a SAST tool for detecting hardcoded secrets like passwords,
      API keys and tokens in git repos.
    '';

    homepage = "https://github.com/gitleaks/gitleaks";
    changelog = "https://github.com/gitleaks/gitleaks/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      friedow
    ];

    mainProgram = "gitleaks";
  };
}
