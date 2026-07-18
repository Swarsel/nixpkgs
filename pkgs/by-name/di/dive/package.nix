{
  lib,
  stdenv,
  fetchFromGitHub,
  btrfs-progs,
  buildGoModule,
  gpgme,
  installShellFiles,
  lvm2,
  pkg-config,
}:
buildGoModule (finalAttrs: {
  pname = "dive";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "wagoodman";
    repo = "dive";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PXimdEgcPS1QQbhkaI2a55EIyWMIZTwRWj0Wx81nqcQ=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    btrfs-progs
    gpgme
    lvm2
  ];

  vendorHash = "sha256-egsFnnHZMPRTJeFw6uByE9OJH06zqKRTvQi9XhegbDI=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd dive \
      --bash <($out/bin/dive completion bash) \
      --fish <($out/bin/dive completion fish) \
      --zsh <($out/bin/dive completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Tool for exploring each layer in a docker image";
    homepage = "https://github.com/wagoodman/dive";
    changelog = "https://github.com/wagoodman/dive/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      SuperSandro2000
      ryan4yin
    ];

    mainProgram = "dive";
  };
})
