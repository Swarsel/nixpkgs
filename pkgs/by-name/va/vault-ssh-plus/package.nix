{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  openssh,
  testers,
  vault-ssh-plus,
}:
buildGoModule (finalAttrs: {
  pname = "vault-ssh-plus";
  version = "0.7.9";

  src = fetchFromGitHub {
    owner = "isometry";
    repo = "vault-ssh-plus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-soz4xXVLyR479d+qcLuHq06CZ5afy+jqyIEZblyRlC0=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-eHhs+6sPKkAdMWzh51ICfuejxwqEGeTNSI3P0X4BFSY=";

  postInstall = ''
    mv $out/bin/vault-ssh-plus $out/bin/vssh
    wrapProgram $out/bin/vssh --prefix PATH : ${lib.makeBinPath [ openssh ]};
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "vssh --version";
    package = vault-ssh-plus;
  };

  meta = {
    description = "Automatically use HashiCorp Vault SSH Client Key Signing with ssh(1)";
    homepage = "https://github.com/isometry/vault-ssh-plus";
    changelog = "https://github.com/isometry/vault-ssh-plus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lesuisse ];
    mainProgram = "vssh";
  };
})
