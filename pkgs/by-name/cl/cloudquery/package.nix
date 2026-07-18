{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "cloudquery";
  version = "6.36.1";

  src = fetchFromGitHub {
    owner = "cloudquery";
    repo = "cloudquery";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D0gciTH5OwYXBPabOmn6bMHyWZwS6y5uAQIdNS+WugE=";
  };

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ];

  vendorHash = "sha256-gY/FQ71Nwk9i7QXgMmOVlJe9lEW9ViPZ3Eh1NusIizE=";

  postInstall = ''
    mv $out/bin/cli $out/bin/cloudquery

    installShellCompletion --cmd cloudquery \
       --bash <($out/bin/cloudquery completion bash) \
       --fish <($out/bin/cloudquery completion fish) \
       --zsh <($out/bin/cloudquery completion zsh)
  '';

  doInstallCheck = true;
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/cloudquery/cloudquery/cli/v${lib.versions.major finalAttrs.version}/cmd.Version=${finalAttrs.version}"
  ];

  modRoot = "cli";

  subPackages = [
    "."
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Data pipelines for cloud config and security data";
    homepage = "https://github.com/cloudquery/cloudquery";
    changelog = "https://github.com/cloudquery/cloudquery/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ jlesquembre ];
    mainProgram = "cloudquery";
  };
})
