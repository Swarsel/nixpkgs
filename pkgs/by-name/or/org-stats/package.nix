{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  org-stats,
  replaceVars,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "org-stats";
  version = "1.12.2";

  src = fetchFromGitHub {
    owner = "caarlos0";
    repo = "org-stats";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QTjJ+4Qu5u+5ZCoIAQBxqdhjNI2CXUB8r2Zx8xfIiGw=";
  };

  patches = [
    # patch in version information
    # since `debug.ReadBuildInfo` does not work with `go build
    (replaceVars ./version.patch {
      inherit (finalAttrs) version;
    })
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-0biuv94wGXiME181nlkvozhB+x4waGMgwXD9ColQWPw=";

  postInstall = ''
    $out/bin/org-stats man > org-stats.1
    installManPage org-stats.1

    installShellCompletion --cmd org-stats \
      --bash <($out/bin/org-stats completion bash) \
      --fish <($out/bin/org-stats completion fish) \
      --zsh <($out/bin/org-stats completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "org-stats version";
      package = org-stats;
    };
  };

  meta = {
    description = "Get the contributor stats summary from all repos of any given organization";
    homepage = "https://github.com/caarlos0/org-stats";
    changelog = "https://github.com/caarlos0/org-stats/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "org-stats";
  };
})
