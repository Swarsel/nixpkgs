{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  faac,
  lame,
  libjack2,
  libogg,
  libopus,
  libpulseaudio,
  libsamplerate,
  libvorbis,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "darkice";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "rafael2k";
    repo = "darkice";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-THsw7N80hkcKQmU3spUhTEuCHbGw+pkh3MPp5Isnk7c=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libopus
    libvorbis
    libogg
    libpulseaudio
    alsa-lib
    libsamplerate
    libjack2
    lame
  ];

  configureFlags = [
    "--with-faac-prefix=${faac}"
    "--with-lame-prefix=${lame.lib}"
  ];

  enableParallelBuilding = true;
  sourceRoot = "source/darkice/trunk";

  meta = {
    description = "Live audio streamer";
    homepage = "http://darkice.org/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      ikervagyok
      l33tname
    ];
  };
})
