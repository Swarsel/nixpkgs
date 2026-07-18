{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  flex,
  lemon,
  libGL,
  libGLU,
  libpng,
  libsForQt5,
  makeDesktopItem,
  ncurses,
  python3,
}:

let
  gitRev = "b4b000937376a0ecf7ca1a2e708fb243624e7bdd";
  gitBranch = "develop";
  gitTag = "0.9.3";
in
stdenv.mkDerivation {
  pname = "antimony";
  version = "0.9.3-unstable-2025-10-12";

  src = fetchFromGitHub {
    owner = "mkeeter";
    repo = "antimony";
    rev = gitRev;
    hash = "sha256-O+nzL9XMCbtQiJx4xRs9w8a7uVqroZgxGnY0cydeqmw=";
  };

  patches = [ ./paths-fix.patch ];

  postPatch = ''
    sed -i "s,/usr/local,$out,g" \
    app/CMakeLists.txt app/app/app.cpp app/app/main.cpp
    sed -i "s,python3,${python3.executable}," CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    flex
    lemon
    libsForQt5.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    libpng
    python3
    python3.pkgs.boost
    libGLU
    libGL
    libsForQt5.qtbase
    ncurses
  ];

  cmakeFlags = [
    "-DGITREV=${gitRev}"
    "-DGITTAG=${gitTag}"
    "-DGITBRANCH=${gitBranch}"
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 $src/deploy/icon.svg $out/share/icons/hicolor/scalable/apps/antimony.svg
    install -Dm644 ${./mimetype.xml} $out/share/mime/packages/antimony.xml
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Graphics"
        "Science"
        "Engineering"
      ];

      comment = "Tree-based Modeler";
      desktopName = "Antimony";
      exec = "antimony %f";
      genericName = "CAD Application";
      icon = "antimony";

      mimeTypes = [
        "application/x-extension-sb"
        "application/x-antimony"
      ];

      name = "antimony";
      startupWMClass = "antimony";
    })
  ];

  meta = {
    description = "Computer-aided design (CAD) tool from a parallel universe";
    homepage = "https://github.com/mkeeter/antimony";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.linux;
    mainProgram = "antimony";
  };
}
