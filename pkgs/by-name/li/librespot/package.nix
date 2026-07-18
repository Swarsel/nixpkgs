{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  alsa-plugins,
  avahi-compat,
  config,
  libpulseaudio,
  makeWrapper,
  openssl,
  pkg-config,
  portaudio,
  rustPlatform,
  tlsBackend ? "native-tls", # "native-tls" "rustls-tls-native-roots" "rustls-tls-webpki-roots"
  withALSA ? stdenv.hostPlatform.isLinux,
  withAvahi ? false,
  withDNS-SD ? false,
  withMDNS ? true,
  withPortAudio ? stdenv.hostPlatform.isDarwin,
  withPulseAudio ? config.pulseaudio or stdenv.hostPlatform.isLinux,
  withRodio ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "librespot";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "librespot-org";
    repo = "librespot";
    rev = "v${finalAttrs.version}";
    hash = "sha256-twWndV6z5Cdivz7pfAJzdlIjddEiZPEFnTzipMczmJo=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optional withALSA alsa-lib
  ++ lib.optional withDNS-SD avahi-compat
  ++ lib.optional withPortAudio portaudio
  ++ lib.optional withPulseAudio libpulseaudio;

  cargoHash = "sha256-Kf3w6tD/MQaXXegtiCkFbUcYwr4OMw6ipLxNLxJ2NTQ=";

  postFixup = lib.optionalString withALSA ''
    wrapProgram "$out/bin/librespot" \
      --set ALSA_PLUGIN_DIR '${alsa-plugins}/lib/alsa-lib'
  '';

  buildFeatures = [
    tlsBackend
  ]
  ++ lib.optional withRodio "rodio-backend"
  ++ lib.optional withMDNS "with-libmdns"
  ++ lib.optional withDNS-SD "with-dns-sd"
  ++ lib.optional withALSA "alsa-backend"
  ++ lib.optional withAvahi "with-avahi"
  ++ lib.optional withPortAudio "portaudio-backend"
  ++ lib.optional withPulseAudio "pulseaudio-backend";

  buildNoDefaultFeatures = true;

  meta = {
    description = "Open Source Spotify client library and playback daemon";
    homepage = "https://github.com/librespot-org/librespot";
    changelog = "https://github.com/librespot-org/librespot/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ bennofs ];
    mainProgram = "librespot";
  };
})
