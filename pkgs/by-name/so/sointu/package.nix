{
  lib,
  fetchFromGitHub,
  alsa-lib,
  buildGoModule,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  vulkan-headers,
  wayland,
}:

buildGoModule (finalAttrs: {
  pname = "sointu";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "vsariola";
    repo = "sointu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r/yNjod1yOT+CaOcyxhL0GuHK108CV2arVoqWE0kzco=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libGL
    libxcb
    libxkbcommon
    vulkan-headers
    wayland
    libx11
    libxcursor
    libxfixes
  ];

  vendorHash = "sha256-GFLfUd8Y4TFfdej/zy3VkCUwme2S2uAP39TcfZEv1Bg=";
  proxyVendor = true;

  subPackages = [
    "cmd/sointu-track"
    "cmd/sointu-compile"
    "cmd/sointu-play"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fork of 4klang that can target 386, amd64 and WebAssembly";
    homepage = "https://github.com/vsariola/sointu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ martinimoe ];
    mainProgram = "sointu-track";
  };
})
