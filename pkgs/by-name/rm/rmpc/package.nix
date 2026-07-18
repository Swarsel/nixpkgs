{
  lib,
  fetchFromGitHub,
  cmake,
  installShellFiles,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rmpc";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "mierak";
    repo = "rmpc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IcWn15tKlThuLR8s/4KtaHm4np8B8UaKYQsyEWlQoB4=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    cmake
  ];

  cargoHash = "sha256-DDOJqA5S+JiRCOgAPqw1k1b8SNCLS0aKsJsFqlykZDI=";
  env.VERGEN_GIT_DESCRIBE = finalAttrs.version;

  postInstall = ''
    installManPage target/man/rmpc.1

    installShellCompletion --cmd rmpc \
      --bash target/completions/rmpc.bash \
      --fish target/completions/rmpc.fish \
      --zsh target/completions/_rmpc

    install -m 444 -D assets/rmpc.desktop $out/share/applications/rmpc.desktop
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI music player client for MPD with album art support via kitty image protocol";

    longDescription = ''
      Rusty Music Player Client is a beautiful, modern and configurable terminal-based Music Player
      Daemon client. It was inspired by ncmpcpp and aims to provide an alternative with support for
      album art through kitty image protocol without any ugly hacks. It also features ranger/lf
      inspired browsing of songs and other goodies.
    '';

    homepage = "https://rmpc.mierak.dev/";
    changelog = "https://github.com/mierak/rmpc/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      donovanglover
      faukah
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "rmpc";
  };
})
