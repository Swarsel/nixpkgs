{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  dart-sass,
  git,
  installShellFiles,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "shopware-cli";
  version = "0.15.12";

  src = fetchFromGitHub {
    owner = "shopware";
    repo = "shopware-cli";
    tag = finalAttrs.version;
    hash = "sha256-9T04G88OPjdgHKWpuRAma5HGudVfep0cN5tR+MHL28Q=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-VdFA3Ax3aBsJN/MmJq7YYlP+4NVcDhXegVTCKA6MIQ0=";

  nativeCheckInputs = [
    git
    dart-sass
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd shopware-cli \
      --bash <($out/bin/shopware-cli completion bash) \
      --zsh <($out/bin/shopware-cli completion zsh) \
      --fish <($out/bin/shopware-cli completion fish)
  '';

  preFixup = ''
    wrapProgram $out/bin/shopware-cli \
      --prefix PATH : ${lib.makeBinPath [ dart-sass ]}
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X 'github.com/shopware/shopware-cli/cmd.version=${finalAttrs.version}'"
  ];

  meta = {
    description = "Command line tool for Shopware 6";
    homepage = "https://github.com/shopware/shopware-cli";
    changelog = "https://github.com/shopware/shopware-cli/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ shyim ];
    mainProgram = "shopware-cli";
  };
})
