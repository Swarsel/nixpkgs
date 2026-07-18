{
  lib,
  stdenv,
  fetchFromGitLab,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  boost,
  cmake,
  curl,
  fetchpatch,
  libGL,
  libvorbis,
  libx11,
  pkg-config,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "commandergenius";
  version = "3.5.2";

  src = fetchFromGitLab {
    owner = "Dringgstein";
    repo = "Commander-Genius";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4WfHdgn8frcDVa3Va6vo/jZihf09vIs+bNdAxScgovE=";
  };

  patches = [
    # Fixes a broken build due to a renamed inner struct of SDL_ttf.
    # Should be removable as soon as upstream releases v. 3.5.3.
    (fetchpatch {
      hash = "sha256-bcCzXzh9yDngwHMfQTrnvyDal4YBiBcMTtKTgt9BtDk=";
      name = "fix-sdl-ttf_font_rename.patch";
      url = "https://github.com/gerstrong/Commander-Genius/commit/e8af0d16970d75e94392f57de0992dfddc509bc3.patch";
    })
  ];

  postPatch = ''
    NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE $(sdl2-config --cflags)"
    sed -i 's,APPDIR games,APPDIR bin,' src/install.cmake
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    libGL
    boost
    libvorbis
    zlib
    curl
    python3
    libx11
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DSHAREDIR=${placeholder "out"}/share"
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  meta = {
    description = "Modern Interpreter for the Commander Keen Games";

    longDescription = ''
      Commander Genius is an open-source clone of
      Commander Keen which allows you to play
      the games, and some of the mods
      made for it. All of the original data files
      are required to do so
    '';

    homepage = "https://github.com/gerstrong/Commander-Genius";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ hce ];
    platforms = lib.platforms.linux;
  };
})
