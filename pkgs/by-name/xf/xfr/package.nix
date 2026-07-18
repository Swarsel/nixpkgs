{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xfr";
  version = "0.9.21";

  src = fetchFromGitHub {
    owner = "lance0";
    repo = "xfr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dcXbyiqhj/6VXIlFmk19LocxbfSnGC3aXR70YlUXQkA=";
  };

  nativeBuildInputs = [
    installShellFiles
    versionCheckHook
  ];

  cargoHash = "sha256-A5oYEjJvvS7hWtt9ceD9ewup8rzk8NRP0egQRrQwlzY=";

  postInstall = ''
    installShellCompletion --cmd xfr \
      --bash <($out/bin/xfr --completions bash) \
      --fish <($out/bin/xfr --completions fish) \
      --zsh <($out/bin/xfr --completions zsh)
  '';

  doInstallCheck = true;
  __structuredAttrs = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Modern iperf3 alternative with a live TUI, multi-client server, and QUIC support.";
    homepage = "https://github.com/lance0/xfr";
    changelog = "https://github.com/lance0/xfr/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      _0x4A6F
      herbetom
    ];

    platforms = lib.platforms.linux;
    mainProgram = "xfr";
  };
})
