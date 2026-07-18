{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  icoutils, # build and runtime deps.
  qt6,
  sqlite,
  wget,
  which, # runtime deps.
  wine,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "q4wine";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "brezerk";
    repo = "q4wine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5rj+EDsOZib78gWT003a4IN23cZQftnhVggIdLN6f7I=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    sqlite
    icoutils
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
  ];

  # Add runtime deps.
  postInstall = ''
    wrapProgram $out/bin/q4wine \
      --prefix PATH : ${
        lib.makeBinPath [
          icoutils
          wget
          wine
          which
        ]
      }
  '';

  meta = {
    description = "Qt GUI for Wine to manage prefixes and applications";
    homepage = "https://q4wine.brezblock.org.ua/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ rkitover ];
    platforms = lib.platforms.unix;
  };
})
