{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg_6,
  installShellFiles,
  libdrm,
  nix-update-script,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wl-screenrec";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "russelltg";
    repo = "wl-screenrec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sLuhVeyzFp6sFKGK7Y7DPAPk7IdFAqAtjm56zhrX3fA=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    installShellFiles
  ];

  buildInputs = [
    wayland
    libdrm
    ffmpeg_6
  ];

  cargoHash = "sha256-atfWEAo6tMLEzFtiLlxp8fyVKa1cF/4SZFMYStDYZwU=";
  doCheck = false; # tests use host compositor, etc

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd wl-screenrec \
      --bash <($out/bin/wl-screenrec --generate-completions bash) \
      --fish <($out/bin/wl-screenrec --generate-completions fish) \
      --zsh <($out/bin/wl-screenrec --generate-completions zsh)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "High performance wlroots screen recording, featuring hardware encoding";
    homepage = "https://github.com/russelltg/wl-screenrec";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ colemickens ];
    platforms = lib.platforms.linux;
    mainProgram = "wl-screenrec";
  };
})
