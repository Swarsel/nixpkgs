{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  cmake,
  fetchpatch,
  ffmpeg,
  game-music-emu,
  icu,
  kdePackages,
  kdsingleapplication,
  libarchive,
  libebur128,
  libopenmpt,
  libsndfile,
  libvgm,
  pipewire,
  pkg-config,
  taglib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fooyin";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "fooyin";
    repo = "fooyin";
    tag = "v" + finalAttrs.version;
    hash = "sha256-sQ1zsQ/6OHGPkofiKhusCrpW2XnO+PpMvH1M2OG5Huw=";
  };

  # Remove after next release
  patches = [
    (fetchpatch {
      hash = "sha256-Uvggz2F6DuWYAg20qi8uHkshzCnTLrchambQ/yDyIfA=";
      name = "add-missing-header.patch";
      url = "https://github.com/fooyin/fooyin/commit/7b171c0da2b9289468696424fe51f76e1c365bb5.patch";
    })
  ];

  # Fix compatibility with Qt 6.10.1 - should be fixed in next release
  postPatch = ''
    substituteInPlace src/utils/starrating.cpp \
      --replace-fail '.arg(alignment);' '.arg(alignment.toInt());'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    kdePackages.qttools
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = [
    kdePackages.qcoro
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtwayland
    taglib
    ffmpeg
    icu
    kdsingleapplication
    # output plugins
    alsa-lib
    pipewire
    SDL2
    # input plugins
    libebur128
    libvgm
    libsndfile
    libarchive
    libopenmpt
    game-music-emu
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    # we need INSTALL_FHS to be true as the various artifacts are otherwise just dumped in the root
    # of $out and the fixupPhase cleans things up anyway
    (lib.cmakeBool "INSTALL_FHS" true)
  ];

  env.LANG = "C.UTF-8";

  meta = {
    description = "Customisable music player";
    homepage = "https://www.fooyin.org/";
    changelog = "https://github.com/fooyin/fooyin/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.linux;
    mainProgram = "fooyin";
    downloadPage = "https://github.com/fooyin/fooyin";
  };
})
