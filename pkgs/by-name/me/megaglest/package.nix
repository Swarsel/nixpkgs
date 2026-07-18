{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  bash,
  buildEnv,
  cmake,
  cppunit,
  curl,
  fetchpatch,
  fontconfig,
  freetype,
  ftgl,
  git,
  glew,
  glib,
  libGLU,
  libice,
  libjpeg,
  libogg,
  libpng,
  libsm,
  libvlc,
  libvorbis,
  libx11,
  libxext,
  lua,
  makeWrapper,
  openal,
  pkg-config,
  which,
  wxwidgets_3_2,
  xercesc,
  zenity,
}:
let
  version = "3.13.0";
  lib-env = buildEnv {
    name = "megaglest-lib-env";

    paths = [
      SDL2
      libsm
      libice
      libx11
      libxext
      xercesc
      openal
      libvorbis
      lua
      libjpeg
      libpng
      curl
      fontconfig
      ftgl
      freetype
      stdenv.cc.cc
      glew
      libGLU
      wxwidgets_3_2
    ];
  };
  path-env = buildEnv {
    name = "megaglest-path-env";

    paths = [
      bash
      which
      zenity
    ];
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "megaglest";

  src = fetchFromGitHub {
    owner = "MegaGlest";
    repo = "megaglest-source";
    tag = version;
    sha256 = "0fb58a706nic14ss89zrigphvdiwy5s9dwvhscvvgrfvjpahpcws";
    fetchSubmodules = true;
  };

  patches = [
    # Pull upstream fix for -fno-common toolchains
    (fetchpatch {
      name = "fno-common.patch";
      sha256 = "0y554kjw56dikq87vs709pmq97hdx9hvqsk27f81v4g90m3b3qhi";
      url = "https://github.com/MegaGlest/megaglest-source/commit/5a3520540276a6fd06f7c88e571b6462978e3eab.patch";
    })
    # Pull upstream and Debian fixes for wxWidgets 3.2
    (fetchpatch {
      hash = "sha256-1ZG6AjnLXW18wwad05kjH7W5rTaP1SDpZ5zLH4nRQt4=";
      name = "get-rid-of-manual-wxPaintEvent-creation-1.patch";
      url = "https://github.com/MegaGlest/megaglest-source/commit/e09ba53c436279588f769d6ce8852e74d58f8391.patch";
    })
    (fetchpatch {
      hash = "sha256-aMDDboNdH22r7YOiZCEApwz+FpM60anBp82tLwiIH6g=";
      name = "get-rid-of-manual-wxPaintEvent-creation-2.patch";
      url = "https://sources.debian.org/data/main/m/megaglest/3.13.0-9/debian/patches/fbd0cfb17ed759d24aeb577a602b0d97f7895cc2.patch";
    })
    (fetchpatch {
      hash = "sha256-/RpBoT1JsSFtOrAXphHrPp9DnTbaEN/2h8EZmQ9PIPU=";
      name = "get-rid-of-manual-wxPaintEvent-creation-3.patch";
      url = "https://github.com/MegaGlest/megaglest-source/commit/5801b1fafff8ad9618248d4d5d5c751fdf52be2f.patch";
    })
    (fetchpatch {
      hash = "sha256-fK7vkHCu6bqVB6I7vMsWMGiczSdxVgo1KqqBNMkEbfM=";
      name = "fix-editor-and-g3dviewer-for-wx-3.1.x.patch";
      url = "https://github.com/MegaGlest/megaglest-source/commit/789e1cdf371137b729e832e28a5feb6e97a3a243.patch";
    })
  ];

  postPatch = ''
    substituteInPlace {data/glest_game,.}/CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED( VERSION 2.8.2 )" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
    git
  ];

  buildInputs = [
    curl
    SDL2
    libx11
    xercesc
    openal
    lua
    libpng
    libjpeg
    libvlc
    wxwidgets_3_2
    glib
    cppunit
    fontconfig
    freetype
    ftgl
    glew
    libogg
    libvorbis
    libGLU
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DBUILD_MEGAGLEST=On"
    "-DBUILD_MEGAGLEST_MAP_EDITOR=On"
    "-DBUILD_MEGAGLEST_MODEL_IMPORT_EXPORT_TOOLS=On"
    "-DBUILD_MEGAGLEST_MODEL_VIEWER=On"
  ];

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram $i \
        --prefix LD_LIBRARY_PATH ":" "${lib-env}/lib" \
        --prefix PATH ":" "${path-env}/bin"
    done
  '';

  meta = {
    description = "Entertaining free (freeware and free software) and open source cross-platform 3D real-time strategy (RTS) game";
    homepage = "https://megaglest.org/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.matejc ];
    platforms = lib.platforms.linux;
  };
}
