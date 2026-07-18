{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  installShellFiles,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tmux-sessionizer";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "jrmoulton";
    repo = "tmux-sessionizer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-u2PfLFwqO+VFPWeFumrAJWZjK9JMZF/v0pB0uJ8jfq8=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  cargoHash = "sha256-YVR1m1cosymAKgcsgxSA/iIIF+AJfA92Ibapw0AMfoE=";

  nativeCheckInputs = [
    git
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd tms \
      --bash <(COMPLETE=bash $out/bin/tms) \
      --fish <(COMPLETE=fish $out/bin/tms) \
      --zsh <(COMPLETE=zsh $out/bin/tms)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  meta = {
    description = "Fastest way to manage projects as tmux sessions";
    homepage = "https://github.com/jrmoulton/tmux-sessionizer";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vinnymeller
      mrcjkb
    ];

    mainProgram = "tms";
  };
})
