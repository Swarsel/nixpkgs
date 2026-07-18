{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  autoconf,
  automake,
  boost,
  libice,
  libjpeg,
  libpng,
  libsm,
  libtiff,
  libx11,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "povray";
  version = "3.8.0-beta.2";

  src = fetchFromGitHub {
    owner = "POV-Ray";
    repo = "povray";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-BsWalXzEnymiRbBfE/gsNyWgAqzbxEzO/EQiJpbwoKs=";
  };

  # the installPhase wants to put files into $HOME. I let it put the files
  # to $TMPDIR, so they don't get into the $out
  postPatch = ''
    cd unix
    ./prebuild.sh
    cd ..
    export HOME=$TMPDIR
    sed -i -e 's/^povconfuser.*/povconfuser=$(TMPDIR)\/povray/' Makefile.{am,in}
    sed -i -e 's/^povuser.*/povuser=$(TMPDIR)\/.povray/' Makefile.{am,in}
  '';

  nativeBuildInputs = [
    automake
    autoconf
    pkg-config
  ];

  buildInputs = [
    boost
    libx11
    libice
    libsm
    libpng
    libjpeg
    libtiff
    SDL2
    zlib
  ];

  configureFlags = [
    "COMPILED_BY=NixOS"
    "--with-boost-thread=boost_thread"
    "--with-x"
  ];

  # https://github.com/POV-Ray/povray/issues/460
  env.NIX_CFLAGS_COMPILE = toString [
    "-fno-finite-math-only"
    "-DBOOST_BIND_GLOBAL_PLACEHOLDERS"
  ];

  preInstall = ''
    mkdir "$TMP/bin"
    for i in chown chgrp; do
      echo '#!${stdenv.shell}' >> "$TMP/bin/$i"
      chmod +x "$TMP/bin/$i"
      PATH="$TMP/bin:$PATH"
    done
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Persistence of Vision Raytracer";
    homepage = "http://www.povray.org/";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.linux;
    mainProgram = "povray";
  };
})
