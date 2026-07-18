{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib-with-plugins,
  alsa-plugins,
  nix-update-script,
  pipewire,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  enableSound ? false,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "timr-tui";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "sectore";
    repo = "timr-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/XsYDAvtkbGEtHz68ar2MqONAXyP3i5X0iZ08lnYOu4=";
  };

  nativeBuildInputs = lib.optionals (enableSound && stdenv.hostPlatform.isLinux) [ pkg-config ];

  # Runtime/FFI deps for the sound feature (Linux)
  buildInputs = lib.optionals (enableSound && stdenv.hostPlatform.isLinux) [
    (alsa-lib-with-plugins.override {
      plugins = [
        alsa-plugins
        pipewire
      ];
    })
  ];

  cargoHash = "sha256-DnjKH1EnOY9YnApJDO4R0M7XhxYs5k1f4hoa3J3J32c=";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # Enable upstream "sound" feature when requested
  buildFeatures = lib.optionals enableSound [ "sound" ];
  # Error: Operation not permitted (os error 1)
  versionCheckKeepEnvironment = lib.optionals stdenv.hostPlatform.isDarwin [ "HOME" ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TUI to organize your time: Pomodoro, Countdown, Timer, Event";
    homepage = "https://github.com/sectore/timr-tui";
    changelog = "https://github.com/sectore/timr-tui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      flokkq
      sectore
    ];

    platforms = lib.platforms.unix;
    mainProgram = "timr-tui";
  };
})
