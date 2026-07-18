{
  lib,
  stdenv,
  fetchFromGitHub,
  aubio,
  libpulseaudio,
  libx11,
  libxext,
  libxt,
  motif,
  withAudioTracking ? false,
}:

stdenv.mkDerivation {
  pname = "catclock";
  version = "0-unstable-2021-11-15";

  src = fetchFromGitHub {
    owner = "BarkyTheDog";
    repo = "catclock";
    rev = "b2f277974b5a80667647303cabf8a89d6d6a4290";
    sha256 = "0ls02j9waqg155rj6whisqm7ppsdabgkrln92n4rmkgnwv25hdbi";
  };

  buildInputs = [
    motif
    libx11
    libxext
    libxt
  ]
  ++ lib.optionals withAudioTracking [
    libpulseaudio
    aubio
  ];

  makeFlags = [
    "DESTINATION=$(out)/bin/"
    "CFLAGS=-Wno-incompatible-pointer-types"
  ]
  ++ lib.optional withAudioTracking "WITH_TEMPO_TRACKER=1";

  preInstall = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    cp xclock.man $out/share/man/man1/xclock.1
  '';

  meta = {
    description = "Analog / Digital / Cat clock for X";
    homepage = "http://codefromabove.com/2014/05/catclock/";
    license = with lib.licenses; mit;
    maintainers = with lib.maintainers; [ ramkromberg ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "xclock";
  };
}
