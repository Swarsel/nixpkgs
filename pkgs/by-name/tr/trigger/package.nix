{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  SDL2_image,
  copyDesktopItems,
  freealut,
  glew,
  libGL,
  libGLU,
  makeDesktopItem,
  openal,
  physfs,
  runtimeShell,
  tinyxml-2,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trigger-rally";
  version = "0.6.6.1";

  src = fetchurl {
    url = "mirror://sourceforge/trigger-rally/trigger-rally-${finalAttrs.version}.tar.gz";
    sha256 = "016bc2hczqscfmngacim870hjcsmwl8r3aq8x03vpf22s49nw23z";
  };

  nativeBuildInputs = [ copyDesktopItems ];

  buildInputs = [
    SDL2
    freealut
    SDL2_image
    openal
    physfs
    zlib
    libGLU
    libGL
    glew
    tinyxml-2
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  preConfigure = ''
    sed s,/usr/local,$out, -i bin/*defs

    cd src

    sed s,lSDL2main,lSDL2, -i GNUmakefile
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${lib.getInclude SDL2}/include/SDL2"
  '';

  postInstall = ''
    mkdir -p $out/bin
    cat <<EOF > $out/bin/trigger-rally
    #!${runtimeShell}
    exec $out/games/trigger-rally "$@"
    EOF
    chmod +x $out/bin/trigger-rally

    install -Dm644 $out/share/games/trigger-rally/icon/trigger-rally-icons.svg $out/share/icons/hicolor/scalable/trigger.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ActionGame"
      ];

      comment = "Fast-paced 3D single-player rally racing game";
      desktopName = "Trigger";
      exec = "trigger-rally";
      icon = "trigger";
      name = "Trigger";
    })
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Fast-paced single-player racing game";
    homepage = "http://trigger-rally.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "trigger-rally";
  };
})
