{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  autoconf,
  automake,
  fetchpatch,
  gtk2,
  libGL,
  libGLU,
  libtool,
  m4,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smpeg";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "icculus";
    repo = "smpeg";
    rev = "release_${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    sha256 = "sha256-nq/i7cFGpJXIuTwN/ScLMX7FN8NMdgdsRM9xOD3uycs=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = lib.optionals (!stdenv.hostPlatform.isDarwin) [ ./libx11.patch ] ++ [
    ./format.patch
    ./gcc6.patch
    ./gtk.patch
    # These patches remove use of the `register` storage class specifier,
    # allowing smpeg to build with clang 16, which defaults to C++17.
    (fetchpatch {
      hash = "sha256-GxSD82j05pw0r2SxmPYAe/BXX4iUc+iHWhB9Ap4GzfA=";
      url = "https://github.com/icculus/smpeg/commit/cc114ba0dd8644c0d6205bbce2384781daeff44b.patch";
    })
    (fetchpatch {
      hash = "sha256-U+a6dbc5cm249KlUcf4vi79yUiT4hgEvMv522K4PqUc=";
      url = "https://github.com/icculus/smpeg/commit/b369feca5bf99d6cff50d8eb316395ef48acf24f.patch";
    })
  ];

  postPatch = ''
    substituteInPlace video/gdith.cpp \
      --replace 'register int' 'int' \
      --replace 'register Uint16' 'Uint16'
  '';

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    m4
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    SDL
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    gtk2
    libGLU
    libGL
  ];

  env = lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) {
    NIX_LDFLAGS = "-lX11";
  };

  preConfigure = ''
    touch NEWS AUTHORS ChangeLog
    sh autogen.sh
  '';

  postInstall = ''
    sed -i -e 's,"SDL.h",<SDL/SDL.h>,' \
    -e 's,"SDL_mutex.h",<SDL/SDL_mutex.h>,' \
    -e 's,"SDL_audio.h",<SDL/SDL_audio.h>,' \
    -e 's,"SDL_thread.h",<SDL/SDL_thread.h>,' \
    -e 's,"SDL_types.h",<SDL/SDL_types.h>,' \
      $dev/include/smpeg/*.h

    moveToOutput bin/smpeg-config "$dev"

    wrapProgram $dev/bin/smpeg-config \
      --prefix PATH ":" "${pkg-config}/bin" \
      --prefix PKG_CONFIG_PATH ":" "${lib.getDev SDL}/lib/pkgconfig"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "MPEG decoding library";
    homepage = "https://icculus.org/smpeg/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
})
