{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  imagemagick,
  makeDesktopItem,
  makeWrapper,
  minizinc,
  qt6,
}:

let
  executableLoc =
    if stdenv.hostPlatform.isDarwin then
      "$out/Applications/MiniZincIDE.app/Contents/MacOS/MiniZincIDE"
    else
      "$out/bin/MiniZincIDE";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "minizinc-ide";
  version = "2.9.7";

  src = fetchFromGitHub {
    owner = "MiniZinc";
    repo = "MiniZincIDE";
    rev = finalAttrs.version;
    hash = "sha256-uOWV+mMIczszFg4BuLADRKoOeTQEYecwMKFwH6v6zl8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    qt6.qmake
    makeWrapper
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebsockets
  ];

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv $out/bin/MiniZincIDE.app $out/Applications/
    ''
    + ''
      wrapProgram ${executableLoc} \
        --prefix PATH ":" ${lib.makeBinPath [ minizinc ]} \
        --set QT_QPA_PLATFORM_PLUGIN_PATH "${qt6.qtbase}/lib/qt-6/plugins/platforms"

      for size in 16 24 32 48 64 128 256 512; do
        mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
        magick -background none ${finalAttrs.src}/MiniZincIDE/images/mznicon.png -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/minizinc.png
      done
    '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Science"
        "Development"
        "Education"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "MiniZincIDE";
      exec = "MiniZincIDE";
      icon = "minizinc";
      name = "MiniZincIDE";
      terminal = false;
      type = "Application";
    })
  ];

  dontWrapQtApps = true;
  sourceRoot = "${finalAttrs.src.name}/MiniZincIDE";

  meta = {
    description = "IDE for MiniZinc, a medium-level constraint modelling language";

    longDescription = ''
      MiniZinc is a medium-level constraint modelling
      language. It is high-level enough to express most
      constraint problems easily, but low-level enough
      that it can be mapped onto existing solvers easily and consistently.
      It is a subset of the higher-level language Zinc.
    '';

    homepage = "https://www.minizinc.org/";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "MiniZincIDE";
  };
})
