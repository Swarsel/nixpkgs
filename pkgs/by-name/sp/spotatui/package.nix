{
  lib,
  fetchFromGitHub,
  alsa-lib,
  nix-update-script,
  openssl,
  pipewire,
  pkg-config,
  rustPlatform,
  withPipewireVisualizer ? true,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "spotatui";
  version = "0.40.1";

  src = fetchFromGitHub {
    owner = "LargeModGames";
    repo = "spotatui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kuiL3d5gB37X/WampwDI1r21fP/HWWWR+HDUmKFIhHw=";
  };

  nativeBuildInputs = [ pkg-config ] ++ lib.optional withPipewireVisualizer rustPlatform.bindgenHook;

  buildInputs = [
    alsa-lib
    openssl
  ]
  ++ lib.optional withPipewireVisualizer pipewire;

  cargoHash = "sha256-7j4EdJJy8AZjYYbfa3rotnJeekCBJkZapCI2z6XE3hM=";

  buildFeatures = [
    "cover-art"
    "discord-rpc"
    "mpris"
    "streaming"
    "telemetry"
  ]
  ++ lib.optional withPipewireVisualizer "audio-viz";

  buildNoDefaultFeatures = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fully standalone Spotify client for the terminal";
    homepage = "https://github.com/LargeModGames/spotatui";
    changelog = "https://github.com/LargeModGames/spotatui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lordmzte ];
    # macOS is supported by upstream, but the package maintainer has no way to test this.
    platforms = lib.platforms.linux;
    mainProgram = "spotatui";
  };
})
