{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  jre,
  makeDesktopItem,
  unzip,
}:

let
  desktopItem = makeDesktopItem {
    categories = [ "Utility" ];
    desktopName = "JDiskReport";
    exec = "jdiskreport";
    genericName = "A graphical utility to visualize disk usage";
    name = "jdiskreport";
  };
in
stdenv.mkDerivation rec {
  inherit jre;
  pname = "jdiskreport";
  version = "1.4.1";

  src = fetchurl {
    url = "https://www.jgoodies.com/download/jdiskreport/jdiskreport-${
      lib.replaceStrings [ "." ] [ "_" ] version
    }.zip";

    sha256 = "0d5mzkwsbh9s9b1vyvpaawqc09b0q41l2a7pmwf7386b1fsx6d58";
  };

  nativeBuildInputs = [
    copyDesktopItems
    unzip
  ];

  installPhase = ''
    runHook preInstall

    unzip $src

    jar=$(ls */*.jar)

    mkdir -p $out/share/java
    mv $jar $out/share/java

    mkdir -p $out/bin
    cat > $out/bin/jdiskreport <<EOF
    #! $SHELL -e
    exec $jre/bin/java -jar $out/share/java/$(basename $jar)
    EOF
    chmod +x $out/bin/jdiskreport

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description = "Graphical utility to visualize disk usage";
    homepage = "http://www.jgoodies.com/freeware/jdiskreport/";
    license = lib.licenses.unfreeRedistributable; # TODO freedist, libs under BSD-3
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ kylesferrazza ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "jdiskreport";
  };
}
