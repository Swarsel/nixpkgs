{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "sftpgo-plugin-auth";
  version = "1.0.16";

  src = fetchFromGitHub {
    owner = "sftpgo";
    repo = "sftpgo-plugin-auth";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IKCdWr+ZmuPJxRYdjS3FMNS8CT8oy7tqTSlEwqxyNqw=";
  };

  vendorHash = "sha256-AZWwPwumSNwMUEixm+aarJZlUaT647haVM87qm6oE4U=";
  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-X github.com/sftpgo/sftpgo-plugin-auth/cmd.commitHash=${finalAttrs.src.rev}"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "LDAP/Active Directory authentication for SFTPGo";
    homepage = "https://github.com/sftpgo/sftpgo-plugin-auth";
    changelog = "https://github.com/sftpgo/sftpgo-plugin-auth/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ connor-grady ];
    platforms = lib.platforms.unix;
    mainProgram = "sftpgo-plugin-auth";
  };
})
