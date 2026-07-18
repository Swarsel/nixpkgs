{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  dnsmasq,
  installShellFiles,
  makeWrapper,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "virter";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "LINBIT";
    repo = "virter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Kjk/kLDWwFDgr+PnwBNgsZEP/C4YS8/i1l1lTndpS8Q=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-h/4yQmSPoeAm0p7bYv7xQVk316zl7PB1IcRQlOEDHVQ=";
  # requires network access
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/virter \
      --prefix PATH ":" ${lib.makeBinPath [ dnsmasq ]}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd virter \
      --bash <($out/bin/virter completion bash) \
      --fish <($out/bin/virter completion fish) \
      --zsh <($out/bin/virter completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/LINBIT/virter/cmd.version=${finalAttrs.version}"
    "-X github.com/LINBIT/virter/cmd.builddate=builtByNix"
    "-X github.com/LINBIT/virter/cmd.githash=builtByNix"
  ];

  meta = {
    description = "Command line tool for simple creation and cloning of virtual machines based on libvirt";
    homepage = "https://github.com/LINBIT/virter";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "virter";
  };
})
