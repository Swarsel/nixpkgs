{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  curl,
  dos2unix,
  libGL,
  liberation_ttf,
  libx11,
  libxi,
  makeDesktopItem,
  makeWrapper,
  openal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ClassiCube";
  version = "1.3.8";

  src = fetchFromGitHub {
    owner = "ClassiCube";
    repo = "ClassiCube";
    tag = finalAttrs.version;
    hash = "sha256-AF4cr3ZXCixwiihS+2ayrzVH5eYShkjlfF0myb2PbHM=";
  };

  patches = [
    # Fix hardcoded font paths
    ./font-location.patch
  ];

  postPatch = ''
    # ClassiCube hardcodes locations of fonts.
    # This changes the hardcoded location
    # to the path of liberation_ttf instead
    substituteInPlace src/Platform_Posix.c \
      --replace-fail '%NIXPKGS_FONT_PATH%' "${finalAttrs.font_path}"
    # For some reason, the Makefile doesn't link
    # with libcurl and openal when ClassiCube requires them.
    substituteInPlace Makefile \
      --replace-fail '-lX11 -lXi -lpthread -lGL -ldl -lm' \
                     '-lX11 -lXi -lpthread -lGL -ldl -lm -lcurl -lopenal'
  '';

  nativeBuildInputs = [
    dos2unix
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    libx11
    libxi
    libGL
    curl
    openal
    liberation_ttf
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp 'ClassiCube' "$out/bin"
    # ClassiCube puts downloaded resources
    # next to the location of the executable by default.
    # This doesn't work with Nix
    # as the location of the executable is read-only.
    # We wrap the program to make it put its resources
    # in ~/.local/share instead.
    wrapProgram "$out/bin/ClassiCube" \
      --run 'mkdir -p "$HOME/.local/share/ClassiCube"' \
      --run 'cd       "$HOME/.local/share/ClassiCube"'

    mkdir -p "$out/share/icons/hicolor/256x256/apps"
    cp misc/CCicon.png "$out/share/icons/hicolor/256x256/apps"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Minecraft Classic inspired sandbox game";
      desktopName = finalAttrs.pname;
      exec = "ClassiCube";
      genericName = "Sandbox Block Game";
      icon = "CCicon";
      name = finalAttrs.pname;
    })
  ];

  enableParallelBuilding = true;
  font_path = "${liberation_ttf}/share/fonts/truetype";

  prePatch = ''
    # The ClassiCube sources have DOS-style newlines
    # which causes problems with diff/patch.
    dos2unix 'src/Platform_Posix.c' 'src/Core.h'
  '';

  meta = {
    description = "Lightweight, custom Minecraft Classic/ClassiCube client with optional additions written from scratch in C";
    homepage = "https://www.classicube.net/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ _360ied ];
    platforms = lib.platforms.linux;
    mainProgram = "ClassiCube";
  };
})
