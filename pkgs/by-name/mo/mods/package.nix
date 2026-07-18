{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
  installShellFiles,
  mods,
  testers,
  installManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

buildGoModule (finalAttrs: {
  pname = "mods";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "mods";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CT90uMQc0quQK/vCeLiHH8taEkCSDIcO7Q3aA+oaNmY=";
  };

  nativeBuildInputs = lib.optionals (installManPages || installShellCompletions) [
    installShellFiles
  ];

  vendorHash = "sha256-jtSuSKy6GpWrJAXVN2Acmtj8klIQrgJjNwgyRZIyqyY=";
  # These tests require internet access.
  checkFlags = [ "-skip=^TestLoad/http_url$|^TestLoad/https_url$" ];

  postInstall = ''
    export HOME=$(mktemp -d)
  ''
  + lib.optionalString installManPages ''
    $out/bin/mods man > ./mods.1
    installManPage ./mods.1
  ''
  + lib.optionalString installShellCompletions ''
    installShellCompletion --cmd mods \
      --bash <($out/bin/mods completion bash) \
      --fish <($out/bin/mods completion fish) \
      --zsh <($out/bin/mods completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
  ];

  # Otherwise checks fail with `panic: open /etc/protocols: operation not permitted` when sandboxing is enabled on Darwin
  # https://github.com/NixOS/nixpkgs/pull/381645#issuecomment-2656211797
  modPostBuild = ''
    substituteInPlace vendor/modernc.org/libc/honnef.co/go/netdb/netdb.go \
      --replace-quiet '!os.IsNotExist(err)' '!os.IsNotExist(err) && !os.IsPermission(err)'
  '';

  passthru = {
    tests.version = testers.testVersion {
      command = "HOME=$(mktemp -d) mods -v";
      package = mods;
    };

    updateScript = gitUpdater {
      ignoredVersions = ".(rc|beta).*";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "AI on the command line";
    homepage = "https://github.com/charmbracelet/mods";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      caarlos0
    ];

    mainProgram = "mods";
  };
})
