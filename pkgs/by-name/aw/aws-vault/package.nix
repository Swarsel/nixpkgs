{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  writableTmpDirAsHomeHook,
  xdg-utils,
}:
buildGoModule (finalAttrs: {
  pname = "aws-vault";
  version = "7.12.4";

  src = fetchFromGitHub {
    owner = "ByteNess";
    repo = "aws-vault";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0jPtqViGD0Xfn0yn2Buh4LwVAiSn7YvDMpNZYirHUmk=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-pqD3j1I0zENctgM2lBaYiU3DRCqeq9XIX3jWB2p139I=";
  doCheck = false;

  postInstall = ''
    # make xdg-open overrideable at runtime
    # aws-vault uses https://github.com/skratchdot/open-golang/blob/master/open/open.go to open links
    ${lib.optionalString (
      !stdenv.hostPlatform.isDarwin
    ) "wrapProgram $out/bin/aws-vault --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}"}
    installShellCompletion --cmd aws-vault \
      --bash $src/contrib/completions/bash/aws-vault.bash \
      --fish $src/contrib/completions/fish/aws-vault.fish \
      --zsh $src/contrib/completions/zsh/aws-vault.zsh
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/aws-vault --version 2>&1 | grep ${finalAttrs.version} > /dev/null
  '';

  # set the version. see: aws-vault's Makefile
  ldflags = [
    "-X main.Version=v${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "." ];

  meta = {
    description = "Vault for securely storing and accessing AWS credentials in development environments";
    homepage = "https://github.com/ByteNess/aws-vault";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zimbatm
      er0k
    ];

    mainProgram = "aws-vault";
  };
})
