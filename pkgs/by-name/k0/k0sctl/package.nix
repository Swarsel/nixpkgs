{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  k0sctl,
  testers,
}:

buildGoModule rec {
  pname = "k0sctl";
  version = "0.31.1";

  src = fetchFromGitHub {
    owner = "k0sproject";
    repo = "k0sctl";
    tag = "v${version}";
    hash = "sha256-AbSHyc+Orclm2Cun9QTBqC5AxN1+QOveNzBqzX62vBA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-zc/6fC6VQJp7g2URWivaGW0APVHMa+uyHlBPM4b0bf8=";

  postInstall = ''
    for shell in bash zsh fish; do
      installShellCompletion --cmd ${pname} \
        --$shell <($out/bin/${pname} completion --shell $shell)
    done
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/k0sproject/k0sctl/version.Environment=production"
    "-X=github.com/carlmjohnson/versioninfo.Version=v${version}" # Doesn't work currently: https://github.com/carlmjohnson/versioninfo/discussions/12
    "-X=github.com/carlmjohnson/versioninfo.Revision=v${version}"
  ];

  passthru.tests.version = testers.testVersion {
    # See https://github.com/carlmjohnson/versioninfo/discussions/12
    version = "version: (devel)\ncommit: v${version}\n";
    command = "k0sctl version";
    package = k0sctl;
  };

  meta = {
    description = "Bootstrapping and management tool for k0s clusters";
    homepage = "https://k0sproject.io/";
    changelog = "https://github.com/k0sproject/k0sctl/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nickcao
      qjoly
    ];

    mainProgram = "k0sctl";
  };
}
