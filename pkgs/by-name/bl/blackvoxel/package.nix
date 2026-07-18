{
  lib,
  stdenv,
  fetchFromGitHub,
  glew_1_10,
  imagemagick,
  makeDesktopItem,
  nix-update-script,
  sdl12-compat,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blackvoxel";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "Blackvoxel";
    repo = "Blackvoxel";
    tag = finalAttrs.version;
    hash = "sha256-Uj3TfxAsLddsPiWDcLKjpduqvgVjnESZM4YPHT90YYY=";
  };

  postPatch = ''
    substituteInPlace src/sc_Squirrel3/sq/Makefile --replace-fail " -m64" ""
    substituteInPlace src/sc_Squirrel3/sqstdlib/Makefile --replace-fail " -m64" ""
    substituteInPlace src/sc_Squirrel3/squirrel/Makefile --replace-fail " -m64" ""
  '';

  nativeBuildInputs = [ imagemagick ];

  buildInputs = [
    glew_1_10
    sdl12-compat
  ];

  buildFlags = [ "BV_DATA_LOCATION_DIR=${placeholder "out"}/data" ];

  # data/gui/gametype_back.bmp isn't exactly the official icon but since
  # there is no official icon we use that one
  postBuild = ''
    convert gui/gametype_back.bmp blackvoxel.png
  '';

  postInstall = ''
    install -Dm644 blackvoxel.png $out/share/icons/blackvoxel.png
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "Blackvoxel";
      exec = "blackvoxel";
      icon = "blackvoxel";
      name = "blackvoxel";
    })
  ];

  enableParallelBuilding = true;

  installFlags = [
    "doinstall=true"
    "BV_DATA_INSTALL_DIR=${placeholder "out"}/data"
    "BV_BINARY_INSTALL_DIR=${placeholder "out"}/bin"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sci-Fi game with industry and automation";
    homepage = "https://www.blackvoxel.com";
    changelog = "https://github.com/Blackvoxel/Blackvoxel/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      # blackvoxel
      gpl3Plus
      # Squirrel
      mit
    ];

    maintainers = with lib.maintainers; [
      ethancedwards8
      marcin-serwin
    ];

    platforms = lib.platforms.linux;
  };
})
