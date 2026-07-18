{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  alsa-lib,
  cmake,
  fdk_aac,
  ffmpeg,
  fontconfig,
  lame,
  libGL,
  libass,
  libogg,
  libopus,
  libtheora,
  libva,
  libvorbis,
  libvpx,
  libxext,
  libxfixes,
  openssl,
  pkg-config,
  poppler,
  qt6Packages,
  x264,
}:

let
  inherit (qt6Packages)
    qtbase
    qttools
    qtmultimedia
    qtwebengine
    qmake
    wrapQtAppsHook
    quazip
    ;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openboard";
  version = "1.7.7";

  src = fetchFromGitHub {
    owner = "OpenBoard-org";
    repo = "OpenBoard";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MjUbfv+3o3f4qsLPxLDeUn+/h5YupMMhC/SecwmCR8Q=";
  };

  patches = [
    ./poppler-26-compat.patch # https://github.com/OpenBoard-org/OpenBoard/pull/1474
  ];

  postPatch = ''
    substituteInPlace resources/etc/OpenBoard.config \
      --replace-fail 'EnableAutomaticSoftwareUpdates=true' 'EnableAutomaticSoftwareUpdates=false' \
      --replace-fail 'EnableSoftwareUpdates=true' 'EnableAutomaticSoftwareUpdates=false' \
      --replace-fail 'HideCheckForSoftwareUpdate=false' 'HideCheckForSoftwareUpdate=true'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qttools
    qtwebengine
    qtmultimedia
    libGL
    fontconfig
    openssl
    poppler
    ffmpeg
    libva
    alsa-lib
    SDL
    x264
    libvpx
    libvorbis
    libtheora
    libogg
    libopus
    lame
    fdk_aac
    libass
    quazip
    libxext
    libxfixes
  ];

  # Required by Poppler
  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
  ];

  meta = {
    description = "Interactive whiteboard application";
    homepage = "https://openboard.ch/";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      fufexan
    ];

    platforms = lib.platforms.linux;
    mainProgram = "openboard";
  };
})
