{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  autoconf,
  automake,
  freetype,
  libGL,
  libGLU,
  libmodplug,
  libogg,
  libtheora,
  libtool,
  libvorbis,
  libx11,
  luajit,
  mpg123,
  openal,
  physfs,
  pkg-config,
  which,
}:

stdenv.mkDerivation rec {
  pname = "love";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "love2d";
    repo = "love";
    rev = version;
    sha256 = "19yfmlcx6w8yi4ndm5lni8lrsvnn77bxw5py0dc293nzzlaqa9ym";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    SDL2
    libx11 # SDl2 optional depend, for SDL_syswm.h
    libGLU
    libGL
    openal
    luajit
    freetype
    physfs
    libmodplug
    mpg123
    libvorbis
    libogg
    libtheora
    which
    libtool
  ];

  configureFlags = [
    "--with-lua=luajit"
  ];

  env.NIX_CFLAGS_COMPILE = "-DluaL_reg=luaL_Reg"; # needed since luajit-2.1.0-beta3
  preConfigure = "$shell ./platform/unix/automagic";

  meta = {
    description = "Lua-based 2D game engine/scripting language";
    homepage = "https://love2d.org";
    license = lib.licenses.zlib;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "love";
  };
}
