{
  lib,
  stdenv,
  fetchFromGitHub,
  allegro5,
  cmake,
  libglvnd,
  libx11,
  ninja,
  nix-update-script,
  physfs,
  surgescript,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opensurge";
  version = "0.6.1.2";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "opensurge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HvpKZ62mYy7XkZOnIn7QRA2rFVREFnKO1NO83aCR76k=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 3.1)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    allegro5
    libglvnd
    physfs
    surgescript
    libx11
  ];

  cmakeFlags = [
    "-DGAME_BINDIR=${placeholder "out"}/bin"
    "-DDESKTOP_ICON_PATH=${placeholder "out"}/share/pixmaps"
    "-DDESKTOP_METAINFO_PATH=${placeholder "out"}/share/metainfo"
    "-DDESKTOP_ENTRY_PATH=${placeholder "out"}/share/applications"
    "-DWANT_BUILD_DATE=OFF"
  ];

  # Darwin fails with "Critical error: required built-in appearance SystemAppearance not found"
  doInstallCheck = !stdenv.hostPlatform.isDarwin;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fun 2D retro platformer inspired by Sonic games and a game creation system";
    homepage = "https://opensurge2d.org/";
    changelog = "https://github.com/alemart/opensurge/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "opensurge";
    downloadPage = "https://github.com/alemart/opensurge";
  };
})
