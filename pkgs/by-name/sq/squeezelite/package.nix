{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  faad2,
  ffmpeg,
  flac,
  libgpiod,
  libmad,
  libpulseaudio,
  libvorbis,
  mpg123,
  openssl,
  opusfile,
  portaudio,
  slimserver,
  soxr,
  alsaSupport ? stdenv.hostPlatform.isLinux,
  audioBackend ? if stdenv.hostPlatform.isLinux then "alsa" else "portaudio",
  dsdSupport ? true,
  faad2Support ? true,
  ffmpegSupport ? true,
  opusSupport ? true,
  portaudioSupport ? stdenv.hostPlatform.isDarwin,
  resampleSupport ? true,
  sslSupport ? true,
}:

let
  inherit (lib) optional optionals optionalString;

  pulseSupport = audioBackend == "pulse";

  binName = "squeezelite${optionalString pulseSupport "-pulse"}";
in
stdenv.mkDerivation {
  # the nixos module uses the pname as the binary name
  pname = binName;
  # versions are specified in `squeezelite.h`
  # see https://github.com/ralph-irving/squeezelite/issues/29
  version = "2.0.0.1577";

  src = fetchFromGitHub {
    owner = "ralph-irving";
    repo = "squeezelite";
    rev = "d0d17404467bc18326d9de94eaf3949cf8fb8f59";
    hash = "sha256-mKMlm6oQdrECckBJ7Et6pehimAWd1z07BQsu1njKA50=";
  };

  postPatch = ''
    substituteInPlace opus.c \
      --replace "<opusfile.h>" "<opus/opusfile.h>"
  '';

  buildInputs = [
    flac
    libmad
    libvorbis
    mpg123
  ]
  ++ optional pulseSupport libpulseaudio
  ++ optional alsaSupport alsa-lib
  ++ optional portaudioSupport portaudio

  ++ optional faad2Support faad2
  ++ optional ffmpegSupport ffmpeg
  ++ optional opusSupport opusfile
  ++ optional resampleSupport soxr
  ++ optional sslSupport openssl
  ++ optional (stdenv.hostPlatform.isAarch32 or stdenv.hostPlatform.isAarch64) libgpiod;

  env = {
    EXECUTABLE = binName;

    OPTS = toString (
      [
        "-DLINKALL"
        "-DGPIO"
      ]
      ++ optional dsdSupport "-DDSD"
      ++ optional (!faad2Support) "-DNO_FAAD"
      ++ optional ffmpegSupport "-DFFMPEG"
      ++ optional opusSupport "-DOPUS"
      ++ optional portaudioSupport "-DPORTAUDIO"
      ++ optional pulseSupport "-DPULSEAUDIO"
      ++ optional resampleSupport "-DRESAMPLE"
      ++ optional sslSupport "-DUSE_SSL"
      ++ optional (stdenv.hostPlatform.isAarch32 or stdenv.hostPlatform.isAarch64) "-DRPI"
    );
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    LDADD = toString [
      "-lportaudio"
      "-lpthread"
    ];
  };

  installPhase = ''
    runHook preInstall

    install -Dm555 -t $out/bin                   ${binName}
    install -Dm444 -t $out/share/man/man1 doc/squeezelite.1

    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru = {
    inherit (slimserver) tests;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Lightweight headless squeezebox client emulator";
    homepage = "https://github.com/ralph-irving/squeezelite";
    license = with lib.licenses; [ gpl3Plus ] ++ optional dsdSupport bsd2;
    maintainers = with lib.maintainers; [ adamcstephens ];

    platforms =
      if (audioBackend == "pulse") then
        lib.platforms.linux
      else
        lib.platforms.linux ++ lib.platforms.darwin;

    mainProgram = binName;
  };
}
