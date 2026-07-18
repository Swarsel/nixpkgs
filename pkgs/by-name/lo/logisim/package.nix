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

stdenv.mkDerivation (finalAttrs: {
  pname = "logisim";
  version = "2.7.1";

  src = fetchurl {
    url = "mirror://sourceforge/project/circuit/${lib.versions.majorMinor finalAttrs.version}.x/${finalAttrs.version}/logisim-generic-${finalAttrs.version}.jar";
    hash = "sha256-Nip4wSrRjCA/7YaIcsSgHNnBIUE3nZLokrviw35ie8I=";
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
    makeWrapper ${jre}/bin/java $out/bin/logisim --add-flags "-jar $src"

    # Create icons
    unzip $src "resources/logisim/img/*"
    for size in 16 20 24 48 64 128
    do
      install -Dm444 "./resources/logisim/img/logisim-icon-$size.png" "$out/share/icons/hicolor/''${size}x''${size}/apps/logisim.png"
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Education" ];
      comment = finalAttrs.meta.description;
      desktopName = "Logisim";
      exec = "logisim";
      icon = "logisim";
      name = "logisim";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "Educational tool for designing and simulating digital logic circuits";
    homepage = "http://www.cburch.com/logisim/";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.unix;
    mainProgram = "logisim";
  };
})
