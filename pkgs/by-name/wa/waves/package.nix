{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildGoModule,
  nix-update-script,
  pkg-config,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "waves";
  version = "0.1.46";

  src = fetchFromGitHub {
    owner = "llehouerou";
    repo = "waves";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vl9xMUo6vaJfGAc5Cj1+bLPFYOVvZt+ZB0lkD+i8dtI=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];
  vendorHash = "sha256-lps0OdY8KoILJh/roY78iC+bYHPeENioQoIsL6v/N0A=";
  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keyboard-driven terminal music player with Soulseek integration, Last.fm scrobbling, and radio mode";
    homepage = "https://github.com/llehouerou/waves";
    changelog = "https://github.com/llehouerou/waves/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ llehouerou ];
    mainProgram = "waves";
  };
})
