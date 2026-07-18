{
  lib,
  fetchurl,
  copyDesktopItems,
  jre8,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "jflap";
  version = "7.1";

  src = fetchurl {
    url = "https://www.jflap.org/jflaptmp/july27-18/JFLAP${version}.jar";
    sha256 = "oiwJXdxWsYFj6Ovu7xZbOgTLVw8160a5YQUWbgbJlAY=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    jre8
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/java
    cp -s $src $out/share/java/jflap.jar
    makeWrapper ${jre8}/bin/java $out/bin/jflap \
      --prefix _JAVA_OPTIONS " " "-Dawt.useSystemAAFontSettings=gasp" \
      --add-flags "-jar $out/share/java/jflap.jar"
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Education"
        "ComputerScience"
        "DataVisualization"
        "Engineering"
        "Java"
      ];

      comment = meta.description;
      desktopName = "jflap";
      exec = "jflap";
      genericName = "Formal language application";

      icon = fetchurl {
        sha256 = "sha256-IiworHI+GT6Fm6B0E+FXnKe+hN8nZYPrxHGZFAcsWDw=";
        url = "https://www.jflap.org/jflapLogo2.jpg";
      };

      name = "jflap";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "GUI tool for experimenting with formal languages topics";
    homepage = "https://www.jflap.org/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      grnnja
    ];

    platforms = jre8.meta.platforms;
  };
}
