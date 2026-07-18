{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kopia,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kopia";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "kopia";
    repo = "kopia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yjeLV7N/U88oVdP4iJYgSM/QJLAMREaB/2jBcbTDWkA=";
  };

  postPatch = ''
    substituteInPlace internal/mount/mount_posix_webdav_helper_linux.go \
      --replace-fail "/usr/bin/mount" "mount" \
      --replace-fail "/usr/bin/umount" "umount"
  '';

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-5p/MUNkqNb+iAFxXXYRR2NB1WiGVIcNrTADsd/VjapU=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kopia \
      --bash <($out/bin/kopia --completion-script-bash) \
      --zsh <($out/bin/kopia --completion-script-zsh)
  '';

  __structuredAttrs = true;

  ldflags = [
    "-X github.com/kopia/kopia/repo.BuildVersion=${finalAttrs.version}"
    "-X github.com/kopia/kopia/repo.BuildInfo=${finalAttrs.src.rev}"
  ];

  subPackages = [ "." ];

  passthru = {
    tests = {
      kopia-version = testers.testVersion {
        package = kopia;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-platform backup tool with fast, incremental backups, client-side end-to-end encryption, compression and data deduplication";
    homepage = "https://kopia.io";
    changelog = "https://github.com/kopia/kopia/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      bbigras
      kilyanni
      nadir-ishiguro
    ];

    mainProgram = "kopia";
  };
})
