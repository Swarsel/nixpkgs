{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  libGL,
  libpulseaudio,
  libxkbcommon,
  nix-update-script,
  pipewire,
  pkg-config,
  rustPlatform,
  udev,
  vulkan-loader,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ashell";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "MalpenZibo";
    repo = "ashell";
    tag = finalAttrs.version;
    hash = "sha256-QRNEc2HNqA1tZk/jW/MXDwXda58yNlkw86SCTjH1/1w=";
  };

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libpulseaudio
    libxkbcommon
    pipewire
    udev
  ]
  ++ finalAttrs.runtimeDependencies;

  cargoHash = "sha256-bLZcRASBGV9Y/QlDVBdOl2ElZDLI1KUAh5MlOsjmlKs=";

  runtimeDependencies = [
    wayland
    libGL
    vulkan-loader
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ready to go Wayland status bar for Hyprland";
    homepage = "https://github.com/MalpenZibo/ashell";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ justdeeevin ];
    platforms = lib.platforms.linux;
    mainProgram = "ashell";
  };
})
