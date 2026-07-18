{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  # deps for audio backends
  alsa-lib,
  cmake,
  dbus,
  fontconfig,
  gst_all_1,
  installShellFiles,
  libjack2,
  libpulseaudio,
  libsixel,
  makeBinaryWrapper,
  # passthru
  nix-update-script,
  openssl,
  pkg-config,
  portaudio,
  rustPlatform,
  writableTmpDirAsHomeHook,
  withAudioBackend ? "rodio", # alsa, pulseaudio, rodio, portaudio, jackaudio, rodiojack, sdl, gstreamer
  withDaemon ? true,
  withFuzzy ? true,
  withImage ? true,
  withMediaControl ? true,
  withNotify ? true,
  withSixel ? true,
  # build options
  withStreaming ? true,
}:

assert lib.assertOneOf "withAudioBackend" withAudioBackend [
  ""
  "alsa"
  "pulseaudio"
  "rodio"
  "portaudio"
  "jackaudio"
  "rodiojack"
  "sdl"
  "gstreamer"
];

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "spotify-player";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "aome510";
    repo = "spotify-player";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SxzQdQOg+KS6jXJNifVkehR91g6gTHBYgyxfXx9WWI8=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    rustPlatform.bindgenHook
    installShellFiles
    # Tries to access $HOME when installing shell files, and on Darwin
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  buildInputs = [
    openssl
    dbus
    fontconfig
  ]
  ++ lib.optionals withSixel [ libsixel ]
  ++ lib.optionals (withAudioBackend == "alsa") [ alsa-lib ]
  ++ lib.optionals (withAudioBackend == "pulseaudio") [ libpulseaudio ]
  ++ lib.optionals (withAudioBackend == "rodio" && stdenv.hostPlatform.isLinux) [ alsa-lib ]
  ++ lib.optionals (withAudioBackend == "portaudio") [ portaudio ]
  ++ lib.optionals (withAudioBackend == "jackaudio") [ libjack2 ]
  ++ lib.optionals (withAudioBackend == "rodiojack") [
    alsa-lib
    libjack2
  ]
  ++ lib.optionals (withAudioBackend == "sdl") [ SDL2 ]
  ++ lib.optionals (withAudioBackend == "gstreamer") [
    gst_all_1.gstreamer
    gst_all_1.gst-devtools
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  cargoHash = "sha256-TmGdJXKOsTL9HVyEEe3PtiLMSDJV/TRokRBVAUdHL7I=";

  postInstall =
    let
      inherit (lib.strings) optionalString;
    in
    # sixel-sys is dynamically linked to libsixel
    optionalString (stdenv.hostPlatform.isDarwin && withSixel) ''
      wrapProgram $out/bin/spotify_player \
        --prefix DYLD_LIBRARY_PATH : "${lib.makeLibraryPath [ libsixel ]}"
    ''
    + optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd spotify_player \
        --bash <($out/bin/spotify_player generate bash) \
        --fish <($out/bin/spotify_player generate fish) \
         --zsh <($out/bin/spotify_player generate zsh)
    '';

  buildFeatures =
    [ ]
    ++ lib.optionals (withAudioBackend != "") [ "${withAudioBackend}-backend" ]
    ++ lib.optionals withMediaControl [ "media-control" ]
    ++ lib.optionals withImage [ "image" ]
    ++ lib.optionals withDaemon [ "daemon" ]
    ++ lib.optionals withNotify [ "notify" ]
    ++ lib.optionals withStreaming [ "streaming" ]
    ++ lib.optionals withSixel [ "sixel" ]
    ++ lib.optionals withFuzzy [ "fzf" ];

  buildNoDefaultFeatures = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Terminal spotify player that has feature parity with the official client";
    homepage = "https://github.com/aome510/spotify-player";
    changelog = "https://github.com/aome510/spotify-player/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      xyven1
      _71zenith
      caperren
      mattkang
    ];

    mainProgram = "spotify_player";
  };
})
