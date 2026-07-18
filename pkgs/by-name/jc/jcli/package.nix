{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "jcli";
  version = "0.0.47";

  src = fetchFromGitHub {
    owner = "jenkins-zh";
    repo = "jenkins-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HsuYTgGe0cDRAG5FP77CGJG+xCDSWjBthPeAclmqd44=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-Ld59i91k1tyR9BhlRohHiRPB8Zt3rQWMtRw+J+13TFw=";
  doCheck = false;

  postInstall =
    let
      jcliBin =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          "$out"
        else
          lib.getBin buildPackages.jcli;
    in
    ''
      mv $out/bin/{jenkins-cli,jcli}

      installShellCompletion --cmd jcli \
        --bash <(${jcliBin}/bin/jcli completion --type bash) \
        --fish <(${jcliBin}/bin/jcli completion --type fish) \
        --zsh <(${jcliBin}/bin/jcli completion --type zsh)
    '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/linuxsuren/cobra-extension/version.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Jenkins CLI allows you to manage your Jenkins in an easy way";
    homepage = "https://github.com/jenkins-zh/jenkins-cli";
    changelog = "https://github.com/jenkins-zh/jenkins-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "jcli";
  };
})
