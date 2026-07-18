{
  lib,
  stdenv,
  fetchFromGitHub,
  boring,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "boring";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "alebeck";
    repo = "boring";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Llc/zxra07DD3pxsUZGAKN2ltegCeTMTI/jSg76gn3U=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-yjqJ7G9n3c1ABLWynswzLP7B6bSwH1dIYKfVZqJX30g=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd boring      \
      --bash <($out/bin/boring --shell bash) \
      --fish <($out/bin/boring --shell fish) \
      --zsh  <($out/bin/boring --shell zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/alebeck/boring/internal/buildinfo.Version=${finalAttrs.version}"
    "-X github.com/alebeck/boring/internal/buildinfo.Commit=${
      builtins.substring 0 5 finalAttrs.src.rev
    }"
  ];

  subPackages = [ "cmd/boring" ];

  passthru = {
    tests.version = testers.testVersion {
      version = "boring ${finalAttrs.version}";
      command = "boring version";
      package = boring;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "SSH tunnel manager";
    homepage = "https://github.com/alebeck/boring";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jacobkoziej
    ];

    mainProgram = "boring";
  };
})
