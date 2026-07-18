{
  lib,
  fetchurl,
  jre,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "bluemap";
  version = "5.16";

  src = fetchurl {
    url = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v${version}/BlueMap-${version}-cli.jar";
    hash = "sha256-eUDVYYkDc4l/j2vpGlLnZUYfQOW+ThxEAQBAc+4NJYA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    makeWrapper ${jre}/bin/java $out/bin/bluemap --add-flags "-jar $src"
    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "3D minecraft map renderer";
    homepage = "https://bluemap.bluecolored.de/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      dandellion
      h7x4
    ];

    mainProgram = "bluemap";
  };
}
