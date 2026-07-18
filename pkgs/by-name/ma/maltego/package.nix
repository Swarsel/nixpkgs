{
  lib,
  stdenv,
  copyDesktopItems,
  fetchzip,
  gawk,
  giflib,
  icoutils,
  jre,
  makeBinaryWrapper,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "maltego";
  version = "4.11.1";

  src = fetchzip {
    url = "https://downloads.maltego.com/maltego-v4/linux/Maltego.v${finalAttrs.version}.linux.zip";
    hash = "sha256-9VDArX8fc4Orh5xCILX7n2teB6cRUABTkCYaStPoa80=";
  };

  postPatch = ''
    substituteInPlace bin/maltego \
      --replace-fail /usr/bin/awk ${lib.getExe gawk}
  '';

  nativeBuildInputs = [
    icoutils
    makeBinaryWrapper
    copyDesktopItems
  ];

  buildInputs = [
    jre
    giflib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    chmod +x bin/maltego

    icotool -x bin/maltego.ico

    for size in 16 32 48 256
    do
      mkdir -p $out/share/icons/hicolor/$size\x$size/apps
      cp maltego_*_$size\x$size\x32.png $out/share/icons/hicolor/$size\x$size/apps/maltego.png
    done

    rm -r *.png

    cp -aR . "$out/share/maltego/"

    makeWrapper $out/share/maltego/bin/maltego $out/bin/maltego \
      --set JAVA_HOME ${jre} \
      --prefix PATH : ${lib.makeBinPath [ jre ]}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "Security"
      ];

      comment = "An open source intelligence and forensics application";
      desktopName = "Maltego";
      exec = "maltego";
      icon = "maltego";
      name = "maltego";
      startupNotify = false;
    })
  ];

  meta = {
    description = "Open source intelligence and forensics application, enabling to easily gather information about DNS, domains, IP addresses, websites, persons, and so on";
    homepage = "https://www.maltego.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      emilytrau
    ];

    platforms = lib.platforms.unix;
    mainProgram = "maltego";
  };
})
