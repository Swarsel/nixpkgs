{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  sqlcmd,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "sqlcmd";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "go-sqlcmd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-FZJiIC8rhZGE0nLY81GUHVXouvhNbx5gj+Xy2z8uxjw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-y2AuRgi8o2ttGkBI/rUEtMbcoIj/BvpVdSVamDbaCpo=";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  postInstall = ''
    mv $out/bin/modern $out/bin/sqlcmd

    installShellCompletion --cmd sqlcmd \
      --bash <($out/bin/sqlcmd completion bash) \
      --fish <($out/bin/sqlcmd completion fish) \
      --zsh <($out/bin/sqlcmd completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "cmd/modern" ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "sqlcmd --version";
    package = sqlcmd;
  };

  meta = {
    description = "Command line tool for working with Microsoft SQL Server, Azure SQL Database, and Azure Synapse";
    homepage = "https://github.com/microsoft/go-sqlcmd";
    changelog = "https://github.com/microsoft/go-sqlcmd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ratsclub ];
    mainProgram = "sqlcmd";
  };
})
