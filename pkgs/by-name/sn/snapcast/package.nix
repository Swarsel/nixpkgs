{
  lib,
  stdenv,
  fetchFromGitHub,
  aixlog,
  alsa-lib,
  asio,
  avahi,
  boost,
  cmake,
  config,
  expat,
  flac,
  libogg,
  libopus,
  libpulseaudio,
  libvorbis,
  nixosTests,
  openssl,
  pipewire,
  pkg-config,
  popl,
  soxr,
  pipewireSupport ? stdenv.hostPlatform.isLinux,
  pulseaudioSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "snapcast";
  version = "0.35.0";

  src = fetchFromGitHub {
    owner = "badaix";
    repo = "snapcast";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kUw4yQpCxgjP4hH2Lpxc7l+ufhYSKs7xL80aJuPrqOo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  # snapcast also supports building against tremor but as we have libogg, that's
  # not needed
  buildInputs = [
    boost
    asio
    avahi
    expat
    flac
    libogg
    libvorbis
    libopus
    aixlog
    popl
    soxr
    openssl
  ]
  ++ lib.optional pulseaudioSupport libpulseaudio
  ++ lib.optional pipewireSupport pipewire
  ++ lib.optional stdenv.hostPlatform.isLinux alsa-lib;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_WITH_PULSE" pulseaudioSupport)
    (lib.cmakeBool "BUILD_WITH_PIPEWIRE" pipewireSupport)
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    TARGET = "MACOS";
  };

  # Upstream systemd unit files are pretty awful, so we provide our own in a
  # NixOS module. It might make sense to get that upstreamed...
  postInstall = ''
    install -d $out/share/doc/snapcast
    cp -r ../doc/* ../*.md $out/share/doc/snapcast
  '';

  passthru.tests.snapcast = nixosTests.snapcast;

  meta = {
    description = "Synchronous multi-room audio player";
    homepage = "https://github.com/badaix/snapcast";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
