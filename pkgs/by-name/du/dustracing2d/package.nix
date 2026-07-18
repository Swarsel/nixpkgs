{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libGL,
  libGLU,
  libogg,
  libvorbis,
  nix-update-script,
  openal,
  pkg-config,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dustracing2d";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "juzzlin";
    repo = "DustRacing2D";
    tag = finalAttrs.version;
    hash = "sha256-1+oKSO0pjUBgnlM9J2BB7Xyqbk8liebzUqxKY5M82qg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6Packages.wrapQtAppsHook
    qt6Packages.qttools
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qtwayland
    openal
    libvorbis
    libogg
    libGL
    libGLU
  ];

  cmakeFlags = [
    "-DReleaseBuild=ON"
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Top-down 2D racing game with split-screen multiplayer";
    homepage = "https://juzzlin.github.io/DustRacing2D/index.html";
    changelog = "https://github.com/juzzlin/DustRacing2D/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ castorNova2 ];
    platforms = lib.platforms.unix;
    mainProgram = "dustrac-game";
    downloadPage = "https://github.com/juzzlin/DustRacing2D";
  };
})
