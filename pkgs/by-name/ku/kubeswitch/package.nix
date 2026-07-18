{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kubeswitch,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubeswitch";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "danielfoehrKn";
    repo = "kubeswitch";
    rev = finalAttrs.version;
    hash = "sha256-899hHqXxx2OuWII4ego6F62EnFIszaYqTTcU9wO2csw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = ''
    mv $out/bin/main $out/bin/switcher
    for shell in bash zsh fish; do
      $out/bin/switcher --cmd switcher completion $shell > switcher.$shell
      installShellCompletion --$shell switcher.$shell
    done
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/danielfoehrkn/kubeswitch/cmd/switcher.version=${finalAttrs.version}"
    "-X github.com/danielfoehrkn/kubeswitch/cmd/switcher.buildDate=1970-01-01"
  ];

  subPackages = [ "cmd/main.go" ];
  passthru.tests.version = testers.testVersion { package = kubeswitch; };

  meta = {
    description = "Kubectx for operators, a drop-in replacement for kubectx";
    homepage = "https://github.com/danielfoehrKn/kubeswitch";
    changelog = "https://github.com/danielfoehrKn/kubeswitch/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "switcher";
  };
})
