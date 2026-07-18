{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  exiv2,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pineapple-pictures";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "BLumia";
    repo = "pineapple-pictures";
    rev = finalAttrs.version;
    hash = "sha256-76DJsJLd7lZqear0FIarmTqL3mlqrrCdwxgXsYmDQNE=";
  };

  nativeBuildInputs = [
    cmake
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtsvg
    exiv2
  ];

  cmakeFlags = [
    "-DPREFER_QT_5=OFF"
  ];

  meta = {
    description = "Homebrew lightweight image viewer";
    homepage = "https://github.com/BLumia/pineapple-pictures";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "ppic";
  };
})
