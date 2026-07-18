{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  desktopToDarwinBundle,
  jre,
  makeBinaryWrapper,
  makeDesktopItem,
  unzip,
}:

let
  icon = fetchurl {
    hash = "sha256-DNRimhNFt6jLdjqv7o2cNz38K6XnevxD0rGymym3xBs=";
    url = "https://github.com/logisim-evolution/logisim-evolution/raw/9e0afa3cd6a8bfa75dab61830822cde83c70bb4b/artwork/logisim-evolution-icon.svg";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "logisim-evolution";
  version = "4.1.0";

  src = fetchurl {
    url = "https://github.com/logisim-evolution/logisim-evolution/releases/download/v${finalAttrs.version}/logisim-evolution-${finalAttrs.version}-all.jar";
    hash = "sha256-/mOGoyF6WRvMMRpO2knh9Do4m0md09D29A80T8hfJXc=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
    unzip
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${jre}/bin/java $out/bin/logisim-evolution --add-flags "-jar $src"
    install -Dm444 ${icon} $out/share/icons/hicolor/scalable/apps/logisim-evolution.svg

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Education" ];
      comment = finalAttrs.meta.description;
      desktopName = "Logisim-evolution";
      exec = "logisim-evolution";
      icon = "logisim-evolution";
      name = "logisim-evolution";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "Digital logic designer and simulator";
    homepage = "https://github.com/logisim-evolution/logisim-evolution";
    changelog = "https://github.com/logisim-evolution/logisim-evolution/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.unix;
    mainProgram = "logisim-evolution";
  };
})
