{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sftpman";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "spantaleev";
    repo = "sftpman-rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-spI+MAjBT+FFD7X+G0ea9Me8wf+8Gn3kids+Dt6OO+w=";
  };

  cargoHash = "sha256-fx3uC9M9q0rXPrakZ5NYLNVQzhKZgqdjjZLQ90TNvqQ=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Application that handles sshfs/sftp file systems mounting";
    homepage = "https://github.com/spantaleev/sftpman-rs";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      contrun
      fugi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "sftpman";
  };
})
