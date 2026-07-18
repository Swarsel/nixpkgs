{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  flac,
  gtk3,
  lame,
  libsForQt5,
  libuchardet,
  monkeys-audio,
  mp3gain,
  opus-tools,
  pkg-config,
  shntool,
  sox,
  taglib,
  vorbis-tools,
  vorbisgain,
  wavpack,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flacon";
  version = "12.0.0";

  src = fetchFromGitHub {
    owner = "flacon";
    repo = "flacon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r9SdQg6JTMoGxO2xUtkkBe5F5cajnsndZEq20BjJGuU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qttools
    libuchardet
    taglib
  ];

  postInstall = ''
    wrapProgram $out/bin/flacon \
      --suffix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}" \
      --prefix PATH : "$bin_path";
  '';

  bin_path = lib.makeBinPath [
    shntool
    flac
    opus-tools
    vorbis-tools
    mp3gain
    lame
    wavpack
    monkeys-audio
    vorbisgain
    sox
  ];

  meta = {
    description = "Extracts audio tracks from an audio CD image to separate tracks";
    homepage = "https://flacon.github.io/";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ snglth ];
    platforms = lib.platforms.linux;
    mainProgram = "flacon";
  };
})
