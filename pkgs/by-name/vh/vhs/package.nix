{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  chromium,
  ffmpeg,
  installShellFiles,
  makeBinaryWrapper,
  ttyd,
}:

buildGoModule (finalAttrs: {
  pname = "vhs";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "vhs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VOiI+ddiax04QtCcDr6ze53kd/HHGbfQE3j/32iq4Ro=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  vendorHash = "sha256-cgKLYUATtn4hMdIOXZe9JWYNUOrX3S6BDfvS+rIWDfM=";

  postInstall = ''
    wrapProgram $out/bin/vhs --prefix PATH : ${
      lib.makeBinPath (
        [
          ffmpeg
          ttyd
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [ chromium ]
      )
    }
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    $out/bin/vhs man > vhs.1
    installManPage vhs.1
    installShellCompletion --cmd vhs \
      --bash <($out/bin/vhs completion bash) \
      --fish <($out/bin/vhs completion fish) \
      --zsh <($out/bin/vhs completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Tool for generating terminal GIFs with code";
    homepage = "https://github.com/charmbracelet/vhs";
    changelog = "https://github.com/charmbracelet/vhs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "vhs";
  };
})
