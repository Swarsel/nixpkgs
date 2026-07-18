{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  bc,
  copyDesktopItems,
  curl,
  freetype,
  libGL,
  libjpeg,
  libogg,
  libvorbis,
  makeBinaryWrapper,
  makeDesktopItem,
  mumble,
  openal,
  opusfile,
  pkg-config,
  speex,
  unstableGitUpdater,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ioquake3";
  version = "0-unstable-2025-05-15";

  src = fetchFromGitHub {
    owner = "ioquake";
    repo = "ioq3";
    rev = "8d2c2b42a55598d99873203194d13161ec2789c6";
    hash = "sha256-OszPRlS5NTvajDZhtGw2wa275O8YodkIgiBz3POouYs=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeBinaryWrapper
    pkg-config
    which
    bc
  ];

  buildInputs = [
    SDL2
    libGL
    openal
    curl
    speex
    opusfile
    libogg
    libvorbis
    libjpeg
    freetype
    mumble
  ];

  preConfigure = ''
    cp ${./Makefile.local} ./Makefile.local
  '';

  preBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace Makefile \
      --replace-fail \
        "-I/Library/Frameworks/SDL2.framework/Headers" \
        "-I${lib.getDev SDL2}/include/SDL2" \
      --replace-fail \
        "CLIENT_LIBS += -framework SDL2" \
        "CLIENT_LIBS += -L${lib.getLib SDL2}/lib -lSDL2" \
      --replace-fail \
        "RENDERER_LIBS += -framework SDL2" \
        "RENDERER_LIBS += -L${lib.getLib SDL2}/lib -lSDL2" \
      --replace-fail \
        "-I/System/Library/Frameworks/OpenAL.framework/Headers" \
        "-I${lib.getDev openal}/include/AL" \
      --replace-fail \
        "CLIENT_LIBS += -framework OpenAL" \
        "CLIENT_LIBS += -L${lib.getLib openal}/lib -lopenal" \
      --replace-fail \
        "TOOLS_CC = gcc" \
        "TOOLS_CC = clang"
  '';

  postBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
    echo "Building Application Bundle for Darwin / macOS"
    # The following script works without extensive patching (see preBuild), as the regular buil already
    # built all the c code and libraries.
    ./make-macosx.sh ${stdenv.hostPlatform.darwinArch}
  '';

  postInstall = ''
    install -Dm644 misc/quake3.svg $out/share/icons/hicolor/scalable/apps/ioquake3.svg

    makeWrapper $out/share/ioquake3/ioquake3.* $out/bin/ioquake3
    makeWrapper $out/share/ioquake3/ioq3ded.* $out/bin/ioq3ded
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv build/release-darwin-${stdenv.hostPlatform.darwinArch}/ioquake3.app $out/Applications/
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ActionGame"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "ioquake3";
      exec = "ioquake3";
      icon = "ioquake3";
      name = "IOQuake3";
    })
  ];

  enableParallelBuilding = true;
  installFlags = [ "COPYDIR=$(out)/share/ioquake3" ];
  installTargets = [ "copyfiles" ];
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Fast-paced 3D first-person shooter, a community effort to continue supporting/developing id's Quake III Arena";
    homepage = "https://ioquake3.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      rvolosatovs
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ioquake3";
  };
})
