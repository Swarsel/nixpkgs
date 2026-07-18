{
  lib,
  stdenv,
  fetchFromGitHub,
  alac,
  alsa-lib,
  autoreconfHook,
  avahi,
  ffmpeg,
  glib,
  libao,
  libconfig,
  libdaemon,
  libgcrypt,
  libjack2,
  libplist,
  libpulseaudio,
  libsndfile,
  libsodium,
  libsoundio,
  libuuid,
  mosquitto,
  nix-update-script,
  openssl,
  pipewire,
  pkg-config,
  popt,
  sndio,
  soxr,
  unixtools,
  enableAirplay2 ? false,
  enableAlac ? !enableAirplay2, # airplay2 build uses ffmpeg for alac
  enableAlsa ? true,
  enableAo ? true,
  enableAvahi ? true,
  enableConvolution ? true,
  enableDbus ? stdenv.hostPlatform.isLinux,
  enableJack ? true,
  enableLibdaemon ? false,
  enableMetadata ? true,
  enableMpris ? stdenv.hostPlatform.isLinux,
  enableMqttClient ? true,
  enablePipe ? true,
  enablePipewire ? true,
  enablePulse ? true,
  enableSndio ? true,
  enableSoundio ? true,
  enableSoxr ? true,
  enableStdout ? true,
  enableTinySVCmDNS ? true,
}:

let
  inherit (lib) optional optionals;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "shairport-sync";
  version = "5.1";

  src = fetchFromGitHub {
    owner = "mikebrady";
    repo = "shairport-sync";
    tag = finalAttrs.version;
    hash = "sha256-az6HxelISTebeKkhK7MIh7px39eCHucSuZb8qBDzptk=";
  };

  postPatch = ''
    sed -i -e 's/G_BUS_TYPE_SYSTEM/G_BUS_TYPE_SESSION/g' dbus-service.c
    sed -i -e 's/G_BUS_TYPE_SYSTEM/G_BUS_TYPE_SESSION/g' mpris-service.c
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    # For glib we want the `dev` output for the same library we are
    # also linking against, since pkgsHostTarget.glib.dev exposes
    # some extra tools that are built for build->host execution.
    # To achieve this, we coerce the output to a string to prevent
    # mkDerivation's splicing logic from kicking in.
    "${glib.dev}"
  ]
  ++ optionals enableAirplay2 [
    libplist.bin
    unixtools.xxd
  ];

  buildInputs = [
    openssl
    popt
    libconfig
  ]
  ++ optional enableAvahi avahi
  ++ optional enableLibdaemon libdaemon
  ++ optional enableAlsa alsa-lib
  ++ optional enableSndio sndio
  ++ optional enableMqttClient mosquitto
  ++ optional enablePulse libpulseaudio
  ++ optional enablePipewire pipewire
  ++ optional enableAo libao
  ++ optional enableJack libjack2
  ++ optional enableSoundio libsoundio
  ++ optional enableSoxr soxr
  ++ optional enableAlac alac
  ++ optional enableConvolution libsndfile
  ++ optionals enableAirplay2 [
    libplist
    libsodium
    libgcrypt
    libuuid
    ffmpeg
  ]
  ++ optional stdenv.hostPlatform.isLinux glib;

  configureFlags = [
    "--without-configfiles"
    "--sysconfdir=/etc"
    "--with-ssl=openssl"
  ]
  ++ optional enableAvahi "--with-avahi"
  ++ optional enablePulse "--with-pulseaudio"
  ++ optional enablePipewire "--with-pipewire"
  ++ optional enableAlsa "--with-alsa"
  ++ optional enableSndio "--with-sndio"
  ++ optional enableAo "--with-ao"
  ++ optional enableJack "--with-jack"
  ++ optional enableSoundio "--with-soundio"
  ++ optional enableStdout "--with-stdout"
  ++ optional enablePipe "--with-pipe"
  ++ optional enableSoxr "--with-soxr"
  ++ optional enableAlac "--with-apple-alac"
  ++ optional enableConvolution "--with-convolution"
  ++ optional enableDbus "--with-dbus-interface"
  ++ optional enableMetadata "--with-metadata"
  ++ optional enableMpris "--with-mpris-interface"
  ++ optional enableMqttClient "--with-mqtt-client"
  ++ optional enableTinySVCmDNS "--with-tinysvcmdns"
  ++ optional enableLibdaemon "--with-libdaemon"
  ++ optional enableAirplay2 "--with-airplay-2";

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script {
    # ignore -dev tagged releases
    extraArgs = [ "--version-regex=^([0-9\\.]+)$" ];
  };

  meta = {
    description = "Airtunes server and emulator with multi-room capabilities";
    homepage = "https://github.com/mikebrady/shairport-sync";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jordanisaacs
    ];

    platforms = lib.platforms.unix;
    mainProgram = "shairport-sync";
  };
})
