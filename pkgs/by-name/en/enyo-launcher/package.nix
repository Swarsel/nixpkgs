{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  qt6,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "enyo-launcher";
  version = "2.0.7";

  src = fetchFromGitLab {
    owner = "sdcofer70";
    repo = "enyo-launcher";
    rev = finalAttrs.version;
    hash = "sha256-Ig1b+JylRlxhl5k5ys9SOGMYw3eUxXyoVXt3YNeWNqI=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [ qt6.qtbase ];

  meta = {
    description = "Frontend for Doom engines";
    homepage = "https://gitlab.com/sdcofer70/enyo-launcher";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.usrfriendly ];
    platforms = lib.platforms.unix;
    mainProgram = "enyo-launcher";
  };
})
