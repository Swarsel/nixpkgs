{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  config,
  libjack2,
  libpcap,
  libpulseaudio,
  pkg-config,
  soxr,
  alsaSupport ? stdenv.hostPlatform.isLinux,
  jackSupport ? false,
  pcapSupport ? false,
  pulseSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scream";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "duncanthrax";
    repo = "scream";
    rev = finalAttrs.version;
    sha256 = "sha256-lP5mdNhZjkEVjgQUEsisPy+KXUqsE6xj6dFWcgD+VGM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs =
    lib.optional pulseSupport libpulseaudio
    ++ lib.optionals jackSupport [
      libjack2
      soxr
    ]
    ++ lib.optional alsaSupport alsa-lib
    ++ lib.optional pcapSupport libpcap;

  cmakeFlags = [
    "-DPULSEAUDIO_ENABLE=${if pulseSupport then "ON" else "OFF"}"
    "-DALSA_ENABLE=${if alsaSupport then "ON" else "OFF"}"
    "-DJACK_ENABLE=${if jackSupport then "ON" else "OFF"}"
    "-DPCAP_ENABLE=${if pcapSupport then "ON" else "OFF"}"
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    set +o pipefail

    # Programs exit with code 1 when testing help, so grep for a string
    $out/bin/scream -h 2>&1 | grep -q Usage:
  '';

  cmakeDir = "../Receivers/unix";

  meta = {
    description = "Audio receiver for the Scream virtual network sound card";
    homepage = "https://github.com/duncanthrax/scream";
    license = lib.licenses.mspl;
    maintainers = with lib.maintainers; [ arcnmx ];
    platforms = lib.platforms.linux;
    mainProgram = "scream";
  };
})
