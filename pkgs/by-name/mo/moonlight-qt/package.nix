{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_ttf,
  alsa-lib,
  fetchpatch,
  ffmpeg,
  libdrm,
  libopus,
  libplacebo,
  libpulseaudio,
  libva,
  libvdpau,
  libxkbcommon,
  nix-update-script,
  openssl,
  pkg-config,
  qt6,
  vulkan-headers,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "moonlight-qt";
  version = "6.1.0";

  src = fetchFromGitHub {
    owner = "moonlight-stream";
    repo = "moonlight-qt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rWVNpfRDLrWsqELPFquA6rW6/AfWV+6DNLUCPqIhle0=";
    fetchSubmodules = true;
  };

  patches = [
    # Fix build for Xcode < 14
    (fetchpatch {
      hash = "sha256-+rXdexZQpOP6yS+oTmvYVxasWxOX16uU1udN75zNX3w=";
      url = "https://github.com/moonlight-stream/moonlight-qt/commit/76deafbd7bf868562d69061e7d6abf2612a2c7ad.patch";
    })
  ];

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
    pkg-config
    vulkan-headers
  ];

  buildInputs = [
    SDL2
    SDL2_ttf
    ffmpeg
    libopus
    libplacebo
    qt6.qtdeclarative
    qt6.qtsvg
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libpulseaudio
    libva
    libvdpau
    libxkbcommon
    qt6.qtwayland
    wayland
    libdrm
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Applications $out/bin
    mv app/Moonlight.app $out/Applications
    ln -s $out/Applications/Moonlight.app/Contents/MacOS/Moonlight $out/bin/moonlight
  '';

  qmakeFlags = [ "CONFIG+=disable-prebuilts" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Play your PC games on almost any device";
    homepage = "https://moonlight-stream.org";
    changelog = "https://github.com/moonlight-stream/moonlight-qt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      azuwis
      zmitchell
    ];

    platforms = lib.platforms.all;
    mainProgram = "moonlight";
  };
})
