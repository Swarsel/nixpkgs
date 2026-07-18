{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "s-search";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "zquestz";
    repo = "s";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aK1M9ypEX1Hl7+poK4czZan/Bqe5+giDiTtlPVjErHY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-GEpBdCByMrCR7doDvp/eVKQzH8Z2kCqetwFivkkUDVU=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd s \
      --bash <($out/bin/s --completion bash) \
      --fish <($out/bin/s --completion fish) \
      --zsh <($out/bin/s --completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  passthru = {
    # `versionCheckHook` fails due to the program requires `sh` to be available in `PATH`
    tests.version = testers.testVersion {
      command = "s --version";
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Web search from the terminal";

    longDescription = ''
      Command-line tool that generates a search query link and opens it in the
      browser of your choice.
    '';

    homepage = "https://github.com/zquestz/s";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      yzx9
    ];

    mainProgram = "s";
  };
})
