{
  lib,
  copyDesktopItems,
  fetchzip,
  jre,
  makeDesktopItem,
  makeWrapper,
  stdenvNoCC,
  extraJavaArgs ? "-Xms512M -Xmx2000M",
}:

stdenvNoCC.mkDerivation rec {
  pname = "gprojector";
  version = "3.1.0";

  src = fetchzip {
    url = "https://www.giss.nasa.gov/tools/gprojector/download/G.ProjectorJ-${version}.tgz";
    sha256 = "sha256-cMmjyitetXxQzfSBh5ry5tIsLWOnBaaYOD1eQg1IX+w=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [ jre ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r $src/jars $out/share/java
    makeWrapper ${jre}/bin/java $out/bin/gprojector --add-flags "-jar $out/share/java/G.Projector.jar" --add-flags "${extraJavaArgs}"
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Science" ];
      comment = meta.description;
      desktopName = "G.Projector";
      exec = "gprojector";
      name = "gprojector";
      startupWMClass = "gov-nasa-giss-projector-GProjector";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  meta = {
    inherit (jre.meta) platforms;
    description = "G.Projector transforms an input map image into any of about 200 global and regional map projections";
    homepage = "https://www.giss.nasa.gov/tools/gprojector/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ pentane ];
  };
}
